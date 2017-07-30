"""Kinda silly example of how to collect stats from running multiple instances.

Runs instances from an asprilo folder and produces a file called "test.csv" with some data about the runs.
"""
from itertools import product
import os
import json
import csv

from robosanta import split_solver, Solver
from santastats import asprilo_merged_instances

# SPLIT = True
# CSV_FILE = "test-split.csv"
SPLIT = False
CSV_FILE = "test.csv"
CONFIGS_ROOT = "configs"

all_configs = ["base_pf.json",]


def single_solver(instance, modules):
    solver = Solver(instance, *modules)
    solver.callSolver(stats_output='stats.json')
    return solver


# Be sure to adjust the path if you intend to run this!!
all_instances = asprilo_merged_instances('/home/quickbeam/aspilro-instances/phillip/tiny_cases/')
counter = 0
rows = []
for config_file, instance in product(all_configs, all_instances):
    # I discovered that even for tiny cases we had to take a limited number of instances
    if counter > 300:
        break

    with open(os.path.join(CONFIGS_ROOT, config_file)) as f:
        config = json.load(f)

    if SPLIT:
        _, solver = split_solver(instance, config['modules_stage_one'], config['modules_stage_two'],
                                 config['incremental-mode'])

        with open("stats-PF.json") as stats_file:
            run_stats_pf = json.load(stats_file)

        with open("stats-TA.json") as stats_file:
            run_stats_ta = json.load(stats_file)

        solvetime = run_stats_pf["summary"]["times"]["solve"] + run_stats_ta["summary"]["times"][
            "solve"]
        groundtime = run_stats_pf["summary"]["times"]["total"] + run_stats_ta["summary"]["times"][
            "total"] - solvetime
    else:
        try:
            solver = single_solver(instance,
                                   config['modules_stage_one'] + config['modules_stage_two'])
            stats_filename = 'stats.json'

            with open(stats_filename) as stats_file:
                run_stats = json.load(stats_file)

            solvetime = run_stats["summary"]["times"]["solve"]
            groundtime = run_stats["summary"]["times"]["total"] - solvetime

        except RuntimeError:
            # Not really sure what's causing this error sometimes, so for now just chugging along ignoring it
            print('runtime error of some sort')
            continue

    counter += 1
    rows.append((config_file, os.path.basename(instance), solver.solved, groundtime, solvetime))

with open(CSV_FILE, 'w') as agg_file:
    aggregator = csv.writer(agg_file)
    aggregator.writerow(["config", "instance", "solved", "ground time", "solve time"])
    aggregator.writerows(rows)
