"""
Tests: Async Functions
"""

import unittest
from aiohttp import web
from aiohttp.test_utils import AioHTTPTestCase
from link_extractor.__main__ import fetch_url
from link_extractor.__main__ import extract_links_from_html
from link_extractor.__main__ import gather_links


class TestAsyncFunctions(AioHTTPTestCase):
    """
    Test cases for asynchronous functions using AioHTTPTestCase.
    """

    async def get_application(self):
        """
        Create a mock application to simulate server responses.

        The mock application defines routes and their corresponding handlers:

        - `/page1`: Returns an HTML response with a link to `/page2`.
        - `/page2`: Returns an HTML response with a link to `/page3`.
        - `/not-found`: Returns a 404 Not Found response.

        :return: An instance of the mock web application.
        :rtype: aiohttp.web.Application
        """

        async def page1_handler(request):
            """
            Handler for `/page1`.

            :param request: The HTTP request object.
            :type request: aiohttp.web.Request
            :return: A response with an HTML link to `/page2`.
            :rtype: aiohttp.web.Response
            """
            if not request:
                raise ValueError("The request is invalid or null")
            return web.Response(text="<a href='/page2'>Link</a>")

        async def page2_handler(request):
            """
            Handler for `/page2`.

            :param request: The HTTP request object.
            :type request: aiohttp.web.Request
            :return: A response with an HTML link to `/page3`.
            :rtype: aiohttp.web.Response
            """
            if not request:
                raise ValueError("The request is invalid or null")
            return web.Response(text="<a href='/page3'>Link</a>")

        async def success_handler(request):
            """
            Handler for `/page2`.

            :param request: The HTTP request object.
            :type request: aiohttp.web.Request
            :return: A response with an HTML link to `/page3`.
            :rtype: aiohttp.web.Response
            """
            if not request:
                raise ValueError("The request is invalid or null")
            return web.Response(text="Fake HTML Content")

        async def not_found_handler(request):
            """
            Handler for `/not-found`.

            :param request: The HTTP request object.
            :type request: aiohttp.web.Request
            :return: A 404 Not Found response.
            :rtype: aiohttp.web.Response
            """
            if not request:
                raise ValueError("The request is invalid or null")
            return web.Response(status=404)

        app = web.Application()
        app.router.add_get("/page1", page1_handler)
        app.router.add_get("/page2", page2_handler)
        app.router.add_get("/success", success_handler)
        app.router.add_get("/not-found", not_found_handler)
        return app

    async def test_fetch_url_success(self):
        """
        Test the `fetch_url` function for a successful request.

        Ensures that the function correctly fetches content from a URL and
        returns the URL and its HTML content.

        :return: None
        """

        url = self.server.make_url("/success")
        async with self.client.session as session:
            fetched_url, content = await fetch_url(session, url)

        self.assertEqual(fetched_url, url)
        self.assertEqual(content, "Fake HTML Content")

    async def test_fetch_url_error(self):
        """
        Test the `fetch_url` function for a 404 Not Found response.

        Ensures that the function correctly handles a 404 status code and
        returns the URL with an empty content string.

        :return: None
        """

        url = self.server.make_url("/not-found")
        async with self.client.session as session:
            fetched_url, content = await fetch_url(session, url)

        self.assertEqual(fetched_url, url)
        self.assertEqual(content, "")

    async def test_fetch_url_exception(self):
        """
        Test the `fetch_url` function for an unreachable host.

        Ensures that the function correctly handles exceptions and
        returns the URL with an empty content string.

        :return: None
        """
        url = "http://nonexistent.url"
        async with self.client.session as session:
            fetched_url, content = await fetch_url(session, url)

        self.assertEqual(fetched_url, url)
        self.assertEqual(content, "")

    async def test_extract_links_from_html(self):
        """
        Test the `extract_links_from_html` function.

        Ensures that the function correctly extracts
        absolute and relative links from HTML content
        and excludes non-HTTP links.

        :return: None
        """

        url = "http://example.com"
        html = """
        <html>
            <body>
                <a href="http://example.com/page1">Page 1</a>
                <a href="/page2">Page 2</a>
                <a href="mailto:someone@example.com">Email</a>
                <a href="#fragment">Fragment</a>
            </body>
        </html>
        """
        fetched_url, links = await extract_links_from_html(url, html)

        self.assertEqual(fetched_url, url)
        self.assertIn("http://example.com/page1", links)
        self.assertIn("http://example.com/page2", links)
        self.assertIn("http://example.com#fragment", links)
        self.assertNotIn("mailto:someone@example.com", links)

    async def test_gather_links(self):
        """
        Test the `gather_links` function.

        Ensures that the function correctly fetches content from multiple URLs,
        extracts links from the content, and organizes the results by domain.

        :return: None
        """

        server_url = str(self.server.make_url("/"))  # Convert to string
        urls = [f"{server_url}page1", f"{server_url}page2"]

        results = await gather_links(urls)

        server_url_base = server_url.rstrip("/")

        self.assertIn(server_url_base, results)
        self.assertIn("/page2", results[server_url_base])
        self.assertIn("/page3", results[server_url_base])


if __name__ == "__main__":
    unittest.main()
