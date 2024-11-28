import asyncio
import aiohttp
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup
import rich_click as click
from rich.console import Console
from rich_click import RichGroup
import json
import re

# Set up Rich Console
console = Console()

# Configure rich-click to use rich styling
click.Group = RichGroup

# URL validation regex
URL_REGEX = re.compile(
    r"^(https?|ftp)://"  # Protocol
    r"([A-Za-z0-9.-]+)"  # Domain name
    r"(:[0-9]+)?"  # Optional port
    r"(/.*)?$"  # Optional path
)


def is_valid_url(url: str):
    """
    Validate the given URL against the regex pattern.
    :param url:
    :return:
    """
    return bool(URL_REGEX.match(url))


async def fetch_url(session, url):
    """
    Fetch the contents of the page with the URL specified.
    :param session:
    :param url:
    :return:
    """
    try:
        async with session.get(url) as response:
            if response.status != 200:
                console.print(f"[bold red]Error:[/bold red] Failed to fetch {url} (status code: {response.status})")
                return url, ""
            return url, await response.text()
    except Exception as e:
        console.print(f"[bold red]Error:[/bold red] Failed to fetch {url} ({e})")
        return url, ""


async def extract_links_from_html(url: str, html: str):
    """
    Extract links from the HTML content of a URL.
    :param url: The absolute URl to retrieve the links from.
    :param html:
    :return:
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
    return url, links


async def gather_links(urls: list[str]):
    """
    Fetch URLs concurrently and extract links.
    :param urls: The list of URLs to gather links from.
    :return:
    """
    results = {}
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
)
@click.option(
    "-o",
    "--output",
    type=click.Choice(["stdout", "json"], case_sensitive=False),
    required=True,
    help="Output format: 'stdout' (one absolute URL per line) or 'json'.",
)
def main(url: list, output: str):
    """
    Extract links from specified URLs and output in the desired format.
    :param url:
    :param output:
    :return:
    """
    # Validate URLs
    valid_urls = [u for u in url if is_valid_url(u)]
    if not valid_urls:
        console.print("[bold red]Error:[/bold red] No valid URLs provided.")
        return

    invalid_urls = set(url) - set(valid_urls)
    if invalid_urls:
        console.print(f"[bold yellow]Warning:[/bold yellow] Invalid URLs ignored: {', '.join(invalid_urls)}")

    console.print("[bold cyan]Fetching and extracting links...[/bold cyan]")
    results = asyncio.run(gather_links(valid_urls))

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
