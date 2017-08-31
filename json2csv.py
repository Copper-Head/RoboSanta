"""Turns a collection of stats JSON files into a CSV.

The point of separating this that collecting all the stats is potentially costly,
so it's better to do that once, get as much as possible and store that,
then extract specific information from them into CSV files taylored to a specific purpose.
"""
from collections import OrderedDict, namedtuple
import csv
import re

from toolz import curry

from fileIO import experiment_item_name, iterate_dir, read_json
from stats_collector import STATS_BASE_DIR

ExperimentData = namedtuple("ExperimentData", "name summary")


def parse_experiment_data(stats_path: str):
    stats = read_json(stats_path)
    return ExperimentData(experiment_item_name(stats_path), stats['summary'])


def get_grid_size(data: ExperimentData):
    m = re.search("_n(\d+)_", data.name)
    return m.group(1) if m else 0


def _get_time(data: ExperimentData, key: str):
    return data.summary['times'][key]


def get_solve_time(data: ExperimentData):
    return _get_time(data, 'solve')


def get_total_time(data: ExperimentData):
    return _get_time(data, 'total')


def get_solved(data: ExperimentData):
    return data.summary['result'] == 1.0 and get_solve_time(data) > 0.0


def get_makespan(data: ExperimentData):
    return data.summary['costs'][0]


# yapf: disable
ENTRIES = OrderedDict([
    ('name', lambda data: data.name),
    ('grid_size', get_grid_size),
    ('solved', get_solved),
    ('total_time', get_total_time),
    ('solve_time', get_solve_time),
    ('plan_makespan', get_makespan)])
# yapf: enable


@curry
def create_row(fields: OrderedDict, data: ExperimentData):
    return dict((field_name, field_getter(data)) for field_name, field_getter in fields.items())


def main():
    with open('stats-new.csv', mode='w') as fh:
        writer = csv.DictWriter(fh, fieldnames=ENTRIES.keys())
        writer.writeheader()
        writer.writerows(
            map(create_row(ENTRIES), map(parse_experiment_data, iterate_dir(STATS_BASE_DIR))))


if __name__ == '__main__':
    main()
