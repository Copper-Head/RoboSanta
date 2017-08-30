import os
import json

from toolz import concat, curry


def experiment_item_name(path):
    """Extract experiment item name from its file path."""
    return os.path.splitext(os.path.basename(path))[0]


def read_json(path):
    """Convenience wrapper for reading json."""
    with open(path) as f:
        return json.load(f)


def dir_filepaths(path):
    for root, _, files in os.walk(path):
        yield map(curry(os.path.join, root), files)


def iterate_dir(path):
    return concat(dir_filepaths(path))
