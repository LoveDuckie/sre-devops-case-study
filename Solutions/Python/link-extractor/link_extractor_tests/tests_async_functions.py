import unittest
from unittest.mock import AsyncMock, patch

import aiohttp
from aiohttp import ClientResponseError

from link_extractor.__main__ import gather_links, extract_links_from_html, fetch_url


class TestAsyncFunctions(unittest.IsolatedAsyncioTestCase):
    """
    Test cases for asynchronous functions related to URL fetching and HTML parsing.
    """

    @patch("aiohttp.ClientSession.get", new_callable=AsyncMock)
    async def test_fetch_url_success(self, mock_get: AsyncMock) -> None:
        """
        Test fetch_url when the URL fetch is successful.
        """
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.text = AsyncMock(return_value="Fake HTML Content")
        mock_get.return_value.__aenter__.return_value = mock_response

        url = "http://example.com"
        async with aiohttp.ClientSession() as session:
            fetched_url, content = await fetch_url(session, url)

        self.assertEqual(fetched_url, url)
        self.assertEqual(content, "Fake HTML Content")

    @patch("aiohttp.ClientSession.get", new_callable=AsyncMock)
    async def test_fetch_url_error(self, mock_get: AsyncMock) -> None:
        """
        Test fetch_url when the server returns a non-200 status code.
        """
        mock_response = AsyncMock()
        mock_response.status = 404
        mock_response.text = AsyncMock(return_value="")
        mock_get.return_value.__aenter__.return_value = mock_response

        url = "http://example.com"
        async with aiohttp.ClientSession() as session:
            fetched_url, content = await fetch_url(session, url)

        self.assertEqual(fetched_url, url)
        self.assertEqual(content, "")

    @patch("aiohttp.ClientSession.get", new_callable=AsyncMock)
    async def test_fetch_url_exception(self, mock_get: AsyncMock) -> None:
        """
        Test fetch_url when an exception is raised during the request.
        """
        mock_get.side_effect = ClientResponseError(None, None, status=500)

        url = "http://example.com"
        async with aiohttp.ClientSession() as session:
            fetched_url, content = await fetch_url(session, url)

        self.assertEqual(fetched_url, url)
        self.assertEqual(content, "")

    async def test_extract_links_from_html(self) -> None:
        """
        Test extract_links_from_html for correct link extraction and conversion of relative URLs.
        """
        url = "http://example.com"
        html = """
        <html>
            <body>
                <a href="http://example.com/page1">Page 1</a>
                <a href="/page2">Page 2</a>
                <a href="mailto:someone@example.com">Email</a>
            </body>
        </html>
        """
        fetched_url, links = await extract_links_from_html(url, html)

        self.assertEqual(fetched_url, url)
        self.assertIn("http://example.com/page1", links)
        self.assertIn("http://example.com/page2", links)  # Relative converted to absolute
        self.assertNotIn("mailto:someone@example.com", links)  # Non-HTTP link excluded

    @patch("aiohttp.ClientSession.get", new_callable=AsyncMock)
    async def test_gather_links(self, mock_get: AsyncMock) -> None:
        """
        Test gather_links to verify concurrent URL fetching and link extraction.
        """
        mock_response_1 = AsyncMock()
        mock_response_1.status = 200
        mock_response_1.text = AsyncMock(return_value="<a href='http://example.com/page1'>Link</a>")

        mock_response_2 = AsyncMock()
        mock_response_2.status = 200
        mock_response_2.text = AsyncMock(return_value="<a href='/page2'>Link</a>")

        mock_get.side_effect = [
            mock_response_1,
            mock_response_2,
        ]

        urls = ["http://example.com", "http://example2.com"]
        results = await gather_links(urls)

        self.assertIn("http://example.com", results)
        self.assertIn("http://example2.com", results)
        self.assertIn("/page1", results["http://example.com"])
        self.assertIn("/page2", results["http://example2.com"])
