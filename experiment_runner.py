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

    with open(config_path) as f:
        config = json.load(f)
    encoding = config['modules_stage_one'] + config['modules_stage_two']
    # We are using bare clingo here because there is no clean way to pass
    # a time limit to the python wrapper and consequently robosanta.
    # Instead of developing some convoluted Python-level control for this
    # we simply take advantage of clingo's existing support for time limits.
    clingo_with_options = [
        # On Ilia's machine the setup is wonky, he's forced to specify
        # the full path of the clingo executable, but someone using a normal
        # setup shouldn't have to worry about this.
        clingo_exec,
        # We do not actually want to see the models.
        "-q",
        # Instead we want to collect as many stats as possible.
        "--stats=2",
        # The time limit is the same as in asprilo paper.
        "--time-limit=1800"
    ]
    for instance_path in tqdm(list(Path(instances).rglob("*.lp"))):
        # For reference on how asprilo instances are structured:
        # https://github.com/potassco/asprilo/blob/master/docs/experiments.md#minimal-horizon-and-task-assignment
        instance_facts = [
            # This is the instance itself.
            instance_path,
            # This is the corresponding task assignment.
            instance_path.with_suffix(".lp__asg-m"),
            # This is the corresponding minimal horizon.
            instance_path.with_suffix(".lp__hor-m"),
        ]
        # Using tqdm instead of printing keeps the progress bar uninterrupted.
        tqdm.write(f"Solving instance: {instance_path.stem}")
        proc = subprocess.run(
            clingo_with_options + encoding + instance_facts,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        tqdm.write('Finished')
        stats_path = stats_dir / instance_path.with_suffix('.stats').name
        with stats_path.open('w') as stats_file:
            # TODO: Parse the stats out of the process stdout!
            stats = {}
            json.dump(stats, stats_file, indent=2, sort_keys=True)
        tqdm.write(f"Done writing to {stats_path}")


if __name__ == '__main__':
    run_experiment()
