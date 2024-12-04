"""
The main application
"""

import asyncio
import json
import logging
import re
import sys
from typing import List, Tuple, Dict
from urllib.parse import urljoin, urlparse, ParseResult

import aiohttp
import rich_click as click
from bs4 import BeautifulSoup
from rich.console import Console
from rich_click import RichGroup

from link_extractor import __title__
from link_extractor.helpers.helpers_logging import (
    get_default_log_filepath,
    get_logger,
)

console = Console()

click.Group = RichGroup

# URL validation regex
URL_REGEX = re.compile(
    r"^(https?|ftp)://"  # Protocol
    r"([A-Za-z0-9.-]+)"  # Domain name
    r"(:[0-9]+)?"  # Optional port
    r"(/.*)?$"  # Optional path
)


def is_valid_url(url: str) -> str:
    """
    Validate the given URL against the regex pattern.

    :param url: The URL string to validate.
    :type url: str
    :return: The same URL if valid.
    :rtype: str
    :raises ValueError: If the URL is invalid or empty.
    """
    if not url:
        raise ValueError("URL cannot be empty")
    if not URL_REGEX.match(url):
        raise ValueError(f"Invalid URL: {url}")
    return url


def validate_urls(
    ctx: click.Context, param: click.Parameter, value: List[str]
) -> List[str]:
    """
    Validate and filter a list of URL options.

    :param ctx: The Click context.
    :type ctx: click.Context
    :param param: The Click parameter.
    :type param: click.Parameter
    :param value: The list of URLs to validate.
    :type value: List[str]
    :return: A list of valid URLs.
    :rtype: List[str]
    :raises click.BadParameter: If no valid URLs are provided.
    """
    if not ctx:
        ValueError("The context is invalid or null")

    if not param:
        raise ValueError("The click parameter is invalid or null")
    if not value:
        raise click.BadParameter("No URLs provided.")
    valid_urls: List[str] = []
    invalid_urls: List[str] = []
    for url in value:
        try:
            valid_urls.append(is_valid_url(url))
        except ValueError:
            invalid_urls.append(url)
    if invalid_urls:
        console.print(
            f"[bold yellow]Warning:[/bold yellow] "
            f"Invalid URLs ignored: {', '.join(invalid_urls)}"
        )
    if not valid_urls:
        raise click.BadParameter("No valid URLs provided.")
    return valid_urls


async def fetch_url(
    session: aiohttp.ClientSession, url: str
) -> Tuple[str, str]:
    """
    Fetch the content of a URL using an aiohttp session.

    :param session: The aiohttp session.
    :type session: aiohttp.ClientSession
    :param url: The URL to fetch.
    :type url: str
    :return: A tuple containing the URL and its HTML content (empty if failed).
    :rtype: Tuple[str, str]
    :raises ValueError: If the URL or session is invalid.
    """
    if not url:
        raise ValueError("URL cannot be empty")
    if not session:
        raise ValueError("Session cannot be None")
    try:
        async with session.get(url) as response:
            if response.status != 200:
                logging.error(
                    f"Failed to fetch {url} (status code: {response.status})"
                )
                return url, ""
            return url, await response.text()
    except Exception as e:
        logging.error(f"Failed to fetch {url} ({e})")
        return url, ""


async def extract_links_from_html(
    url: str, html: str
) -> Tuple[str, List[str]]:
    """
    Extract links from the HTML content of a URL.

    :param url: The base URL to resolve relative links.
    :type url: str
    :param html: The HTML content to parse.
    :type html: str
    :return: A tuple containing the base URL and a list of extracted links.
    :rtype: Tuple[str, List[str]]
    """
    soup = BeautifulSoup(html, "html.parser")
    links = set()
    for a_tag in soup.find_all("a", href=True):
        href = a_tag["href"]
        if href.startswith("mailto:"):
            continue
        if href.startswith("http"):
            links.add(href)
        else:
            links.add(urljoin(url, href))
    return url, list(links)


async def gather_links(urls: List[str]) -> Dict[str, List[str]]:
    """
    Fetch multiple URLs concurrently and extract links.

    :param urls: A list of URLs to fetch and process.
    :type urls: List[str]
    :return: A dictionary mapping domains to their extracted links.
    :rtype: Dict[str, List[str]]
    """
    results: Dict[str, List[str]] = {}
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        responses = await asyncio.gather(*tasks)

        extraction_tasks = [
            extract_links_from_html(url, html)
            for url, html in responses
            if html
        ]
        extracted_links: list[tuple[str, list[str]]] = await asyncio.gather(
            *extraction_tasks
        )

        for base_url, links in extracted_links:
            parsed_url: ParseResult = urlparse(base_url)
            domain = f"{parsed_url.scheme}://{parsed_url.netloc}"
            # If the domain already exists, append links;
            # otherwise, create a new entry
            if domain in results:
                results[domain].extend([urlparse(link).path for link in links])
            else:
                results[domain] = [urlparse(link).path for link in links]

    return results


@click.command()
@click.option(
    "-u",
    "--url",
    multiple=True,
    required=True,
    help="The URLs to process (can specify multiple).",
    callback=validate_urls,
)
@click.option(
    "-o",
    "--output",
    type=click.Choice(["stdout", "json"], case_sensitive=False),
    required=True,
    help="Output format: 'stdout' (one absolute URL per line) or 'json'.",
)
@click.option(
    "-v",
    "--verbosity",
    type=click.Choice(
        [
            name
            for name, level in logging._nameToLevel.items()
            if isinstance(name, str)
        ],
        case_sensitive=False,
    ),
    default=logging._levelToName[logging.DEBUG],
    required=False,
    help="Set the logging level for the application.",
)
@click.option(
    "-l",
    "--log-filepath",
    type=str,
    default=get_default_log_filepath(),
    show_default=True,
    required=False,
    help="The absolute path to where the log file should be stored..",
)
def main(
    url: List[str], output: str, verbosity: str, log_filepath: str
) -> None:
    """
    Extract links from specified URLs and output
    the results in the desired format.

    :param log_filepath:
    :param url: The list of input URLs.
    :type url: List[str]
    :param output: The output format ('stdout' or 'json').
    :type output: str
    :param verbosity: The logging level for the application.
    :type verbosity: str
    """
    _logger: logging.Logger = get_logger(
        filepath=log_filepath, verbosity=logging._nameToLevel[verbosity]
    )
    _logger.info("Starting application (%s)...", __title__)
    results: Dict[str, List[str]] = asyncio.run(gather_links(url))
    if not results:
        raise ValueError("No valid URLs provided.")

    if output == "stdout":
        for domain, paths in results.items():
            absolute_urls = [f"{domain}{path}" for path in paths]
            console.print("\n".join(absolute_urls))
    elif output == "json":
        console.print(json.dumps(results, indent=4))


if __name__ == "__main__":
    try:
        main()
    except Exception as err:
        logging.error(f"Application error: {err}")
        sys.exit(-1)
