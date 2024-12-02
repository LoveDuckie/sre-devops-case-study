import unittest
from unittest.mock import patch, AsyncMock

import aiohttp
from aiohttp import ClientResponseError

from link_extractor.__main__ import is_valid_url, fetch_url, extract_links_from_html, gather_links


class TestURLFunctions(unittest.TestCase):
    """
    Test cases for URL validation functions.
    """

    def test_is_valid_url(self) -> None:
        """
        Test the is_valid_url function with valid and invalid URLs.
        """
        valid_urls = [
            "http://example.com",
            "https://example.com",
            "ftp://example.com",
            "https://example.com/path?query=1",
        ]
        for url in valid_urls:
            self.assertEqual(is_valid_url(url), url, f"URL should be valid: {url}")

        # Test invalid URLs
        invalid_urls = [
            "example.com",
            "://example.com",
            "http:/example.com",
            "https:/example",
        ]
        for url in invalid_urls:
            with self.assertRaises(ValueError, msg=f"URL should be invalid: {url}"):
                is_valid_url(url)

if __name__ == "__main__":
    unittest.main()
