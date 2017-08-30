"""Kinda silly example of how to collect stats from running multiple instances.

Runs instances from an asprilo folder and produces a file called "test.csv" with some data about the runs.
"""
from itertools import product, starmap
import os
import json
from collections import namedtuple

from toolz import compose, curry, juxt
from tqdm import tqdm

from robosanta import Solver, load_files
from fileIO import read_json, experiment_item_name

CONFIGS_ROOT = "configs"

PHILLIP_INSTANCES = "/home/quickbeam/aspilro-instances/phillip"
TOPOLOGY_INSTANCES = "/home/quickbeam/aspilro-instances/topologies"
STATS_BASE_DIR = '/home/quickbeam/aspilro-instances/topologies/stats'

ExperimentalItem = namedtuple("ExperimentalItem", "name filepath config")


def single_solver(item: ExperimentalItem):
    modules = item.config['modules_stage_one'] + item.config['modules_stage_two']
    solver = Solver(item.filepath, *modules, verbose=False)
    solver.solve_normal()
    return solver


def combine_exp_data(config, instance_path):
    instance_name = experiment_item_name(instance_path)
    return ExperimentalItem(instance_name, instance_path, config)


def track_progress(iterable):
    return tqdm(list(iterable))


def get_stats(slvr: Solver):
    return slvr.control.statistics


def write_experiment_stats(filename, stats):
    with open(filename, mode='w') as fhandle:
        json.dump(stats, fhandle, indent=2)


@curry
def stats_outpath(stats_base_dir: str, item: ExperimentalItem, ext=".stats"):
    return os.path.join(stats_base_dir, item.name + ext)


def main():

    all_configs = ["2-robots-ta.json",]

    configs = map(read_json, (os.path.join(CONFIGS_ROOT, fname) for fname in all_configs))

    all_paths = load_files(os.path.join(TOPOLOGY_INSTANCES, 'tiny_cases'))
    items = track_progress(starmap(combine_exp_data, product(configs, all_paths)))
    pipeline = juxt(stats_outpath(STATS_BASE_DIR), compose(get_stats, single_solver))

    for _ in starmap(write_experiment_stats, map(pipeline, items)):
        pass


if __name__ == '__main__':
    main()
