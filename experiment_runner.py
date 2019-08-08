"""Tries to solve multiple instances and collects stats from the runs. """
import json
import subprocess
from pathlib import Path

import click
from tqdm import tqdm


@click.command()
@click.argument("config_path")
@click.argument("instances")
@click.argument("stats_dir")
@click.argument("clingo_exec")
def run_experiment(config_path, instances, stats_dir, clingo_exec="clingo"):
    stats_dir = Path(stats_dir)
    stats_dir.mkdir(parents=True, exist_ok=True)

    for instance_path in tqdm(list(Path(instances).rglob("*.lp"))):
        # For reference on how asprilo instances are structured:
        # https://github.com/potassco/asprilo/blob/master/docs/experiments.md#minimal-horizon-and-task-assignment
        instance_facts = [
            # This is the instance itself.
            instance_path,
            # This is the corresponding minimal horizon.
            instance_path.with_suffix(".lp__hor-m"),
        ]
        # Using tqdm instead of printing keeps the progress bar uninterrupted.
        tqdm.write(f"Solving instance: {instance_path.stem}")

        CALL = ["python", "robosanta.py", "solve", "-c" config_path, "-v"] + instance_facts
        proc = subprocess.run(CALL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        tqdm.write('Finished')
        stats_path = stats_dir / instance_path.with_suffix('.stats').name
        with stats_path.open('w') as stats_file:
            # TODO: Parse the stats out of the process stdout!
            stats_file.write(proc)
        tqdm.write(f"Done writing to {stats_path}")


if __name__ == '__main__':
    run_experiment()
