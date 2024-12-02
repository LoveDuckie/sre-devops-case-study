import asyncio
from typing import List, Tuple, Dict, Union
import aiohttp
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup
import rich_click as click
from rich.console import Console
from rich_click import RichGroup
import json
import re

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
    :param url: URL string to validate
    :return: The same URL if valid
    :raises ValueError: If the URL is invalid
    """
    if not url:
        raise ValueError("URL cannot be empty")
    if not URL_REGEX.match(url):
        raise ValueError(f"Invalid URL: {url}")
    return url


def validate_urls(ctx: click.Context, param: click.Parameter, value: List[str]) -> List[str]:
    """
    Callback to validate and filter URL options.
    :param ctx: Click context
    :param param: Click parameter
    :param value: List of URLs
    :return: List of valid URLs
    """
    if not value:
        raise click.BadParameter("No URLs provided.")
    valid_urls: list[str] = []
    invalid_urls: list[str] = []
    for url in value:
        try:
            valid_urls.append(is_valid_url(url))
        except ValueError:
            invalid_urls.append(url)
    if invalid_urls:
        console.print(f"[bold yellow]Warning:[/bold yellow] Invalid URLs ignored: {', '.join(invalid_urls)}")
    if not valid_urls:
        raise click.BadParameter("No valid URLs provided.")
    return valid_urls


async def fetch_url(session: aiohttp.ClientSession, url: str) -> Tuple[str, str]:
    """
    Fetch the contents of the page with the URL specified.
    :param session: An aiohttp session
    :param url: URL to fetch
    :return: A tuple containing the URL and its HTML content (empty if failed)
    """
    if not url:
        raise ValueError("URL cannot be empty")

    if not session:
        raise ValueError("Session cannot be None")
    try:
        async with session.get(url) as response:
            if response.status != 200:
                console.print(f"[bold red]Error:[/bold red] Failed to fetch {url} (status code: {response.status})")
                return url, ""
            return url, await response.text()
    except Exception as e:
        console.print(f"[bold red]Error:[/bold red] Failed to fetch {url} ({e})")
        return url, ""


async def extract_links_from_html(url: str, html: str) -> Tuple[str, List[str]]:
    """
    Extract links from the HTML content of a URL.
    :param url: The absolute URL to retrieve the links from
    :param html: HTML content of the page
    :return: A tuple containing the base URL and a list of extracted links
    """
    soup = BeautifulSoup(html, "html.parser")
    links = set()
    for a_tag in soup.find_all("a", href=True):
        href = a_tag["href"]
        if href.startswith("http"):
            links.add(href)
        else:
            # Convert relative URLs to absolute URLs
            links.add(urljoin(url, href))
    return url, list(links)


async def gather_links(urls: List[str]) -> Dict[str, List[str]]:
    """
    Fetch URLs concurrently and extract links.
    :param urls: The list of URLs to gather links from
    :return: A dictionary mapping domain names to their extracted links
    """
    results: Dict[str, List[str]] = {}
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        responses = await asyncio.gather(*tasks)

        extraction_tasks = [
            extract_links_from_html(url, html) for url, html in responses if html
        ]
        extracted_links = await asyncio.gather(*extraction_tasks)

        for base_url, links in extracted_links:
            parsed_url = urlparse(base_url)
            domain = f"{parsed_url.scheme}://{parsed_url.netloc}"
            relative_links = [urlparse(link).path for link in links]
            results[domain] = relative_links

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
def main(url: List[str], output: str) -> None:
    """
    Extract links from specified URLs and output in the desired format.
    :param url: List of input URLs
    :param output: Output format, either 'stdout' or 'json'
    """
    console.print("[bold cyan]Fetching and extracting links...[/bold cyan]")
    results = asyncio.run(gather_links(url))

    if output == "stdout":
        # Output all absolute URLs, one per line
        for domain, paths in results.items():
            absolute_urls = [f"{domain}{path}" for path in paths]
            console.print("\n".join(absolute_urls))
    elif output == "json":
        # Output JSON hash
        console.print(json.dumps(results, indent=4))


if __name__ == "__main__":
    main()
