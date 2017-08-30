"""Helper module to house various file I/O and path operations.

The long-term plan is to incorporate it into robosanta.
"""
import os
import json
from itertools import chain


def experiment_item_name(path):
    """Extract experiment item name from its file path."""
    return os.path.splitext(os.path.basename(path))[0]


def read_json(path):
    """Convenience wrapper for reading json."""
    with open(path) as f:
        return json.load(f)


def dir_filepaths(path):
    """Concatenates root path with names of files contained in it."""
    for root, _, files in os.walk(path):
        yield (os.path.join(root, f) for f in files)


def iterate_dir(path):
    """Returns flat iterator over directory and its children."""
    return chain.from_iterable(dir_filepaths(path))
