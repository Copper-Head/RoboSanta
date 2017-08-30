from collections import OrderedDict
import csv

from toolz import curry

from fileIO import experiment_item_name, iterate_dir, read_json
from stats_collector import STATS_BASE_DIR

def _get_time(stats: dict, key: str):
    return stats['summary']['times'][key]


def get_solve_time(stats: dict):
    return _get_time(stats, 'solve')


def get_total_time(stats: dict):
    return _get_time(stats, 'total')


def get_solved(stats: dict):
    return stats['summary']['result'] == 1.0

def get_makespan(stats: dict):
    return stats['summary']['costs'][0]


ENTRIES = OrderedDict([
    # (''),
    ('solved', get_solved),
    ('total_time', get_total_time),
    ('solve_time', get_solve_time),
    ('plan_makespan', get_makespan)])

@curry
def create_row(fields: OrderedDict, json_stats: dict):
    return dict((field_name, field_getter(json_stats)) for field_name, field_getter in fields.items())



def main():
    with open('stats-new.csv', mode='w') as fh:
        writer = csv.DictWriter(fh, fieldnames=ENTRIES.keys())
        writer.writeheader()
        writer.writerows(map(create_row(ENTRIES), map(read_json, iterate_dir(STATS_BASE_DIR))))

if __name__ == '__main__':
    main()
