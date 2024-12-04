"""
Tests: URL Validation Functions
"""

import unittest

from link_extractor.__main__ import (
    is_valid_url,
)


class TestURLFunctions(unittest.TestCase):
    """
    Test cases for URL validation functions.
    """

    def test_is_valid_url(self) -> None:
        """
        Test a set of URLs to determine if they are valid.
        :return:
        """
        valid_urls = [
            "http://example.com",
            "https://example.com",
            "ftp://example.com",
            "https://example.com/path?query=1",
        ]
        for url in valid_urls:
            self.assertEqual(
                is_valid_url(url), url, f"URL should be valid: {url}"
            )

        invalid_urls = [
            "example.com",
            "://example.com",
            "http:/example.com",
            "https:/example",
            "",
        ]
        for url in invalid_urls:
            with self.assertRaises(
                ValueError, msg=f"URL should be invalid: {url}"
            ):
                is_valid_url(url)


if __name__ == "__main__":
    unittest.main()
