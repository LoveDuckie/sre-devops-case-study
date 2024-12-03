"""
Helper functions for logging
"""
import logging
import os
import sys

import logging.handlers

from link_extractor import __title__
from link_extractor.helpers.helpers_datetime import get_time_formatted

_logger: logging.Logger | None = None

def get_default_log_filename() -> str:
    """
    Get the default log file name to use.
    :return: Returns the default log file name.
    """
    return f"{__title__}_{get_time_formatted()}"

def get_default_log_filepath() -> str:
    """
    Get the default log file path.
    :return:
    """
    return os.path.join(os.getcwd(), f"{get_default_log_filename()}")

def _create_logging_handlers(logger: logging.Logger):
    """
    Instantiate the logging handlers
    :param logger:
    :return:
    """
    logger.addHandler(logging.StreamHandler(sys.stdout))
    logger.addHandler(logging.handlers.RotatingFileHandler(get_default_log_filepath()))

def _create_logger() -> logging.Logger:
    """
    Create the logger instance
    :return:
    """
    global _logger
    _logger = logging.Logger(__title__)
    _create_logging_handlers(_logger)
    return _logger

def get_or_create_logger():
    """
    Get the logger if it already exists, otherwise create.
    :return:
    """
    return logging.getLogger(__name__)
