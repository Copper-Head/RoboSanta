"""Provides utilities for running experiments with robosanta.

Also helps collect stats and metrics.
"""
import os


def asprilo_merged_instances(directory):
    """Return iterator over all merged instances in directory."""
    fnames = [(dirpath, filelist) for dirpath, _, filelist in os.walk(directory)
              if os.path.basename(dirpath) == 'merged' and filelist]
    return (os.path.join(dirpath, fname) for dirpath, filelist in fnames for fname in filelist)
