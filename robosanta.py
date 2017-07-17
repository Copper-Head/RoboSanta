from __future__ import print_function
import json
import os

import clingo
import click
from six.moves import input


class Solver(object):

    def __init__(self, instance, *encodings):

        self.control = clingo.Control()

        self.control.load(instance)
        for e in encodings:
            self.control.load(e)

        self.imax = self.get(self.control.get_const("imax"), clingo.Number(100))
        self.istop = self.get(self.control.get_const("istop"), clingo.String("SAT"))

        self.step, self.ret = 1, None
        self.grounded = 0

        self.solved = False

    @staticmethod
    def get(val, default):
        return val if val != None else default

    def solve_incremental(self):
        print("Solving...")
        self.ret = None

        while (self.step < self.imax.number) and\
                (self.ret is None or (self.istop.string == "SAT" and not self.ret.satisfiable)):

            self.control.assign_external(clingo.Function("query", [self.step - 1]), False)

            if self.grounded == 0 and self.step == 1:
                self.control.ground(
                    [("base", []), ("init", []), ("step", [self.step]), ("check", [self.step])])
                self.grounded = 1

            elif self.grounded < self.step:
                parts = []
                parts.append(("check", [self.step]))
                parts.append(("step", [self.step]))
                self.control.cleanup()
                self.control.ground(parts)
                self.grounded += 1

            self.control.assign_external(clingo.Function("query", [self.step]), True)
            self.ret = self.control.solve(on_model=self.on_model)

            self.step += 1

    def solve_normal(self):
        self.control.ground([("base", []), ("init", [])])
        self.control.solve(on_model=self.on_model)

    def on_model(self, model):
        print("Model found")
        self.solved = True

        for atom in model.symbols(shown=True):
            print(atom)

    def stats(self):
        statistics = json.loads(
            json.dumps(
                self.control.statistics, sort_keys=True, indent=4, separators=(',', ': ')))

        self.solvetime = statistics["summary"]["times"]["solve"]
        self.groundtime = statistics["summary"]["times"]["total"] - self.solvetime

        print("solve time: ", self.solvetime)
        print("ground time:", self.groundtime)

    def callSolver(self, multishot=False):
        if multishot:
            self.solve_incremental()
        else:
            self.solve_normal()
        self.stats()
        print("Solved: ", self.solved)


def load_files(path, extension=".lp"):

    file_list = []

    for root, dirs, files in os.walk(path):
        for file_ in files:
            if file_.endswith(extension):
                # use absolute or relative file name in output?
                # file_list.append(os.path.abspath(file_))
                file_list.append(os.path.join(root, file_))

    return file_list


def parse_modules(files):

    # dict will hold all the files for a particular module
    modules = {}

    for file_ in files:
        module_name = file_.split("_")[0]
        if module_name not in modules:
            modules[module_name] = []

        modules[module_name].append(file_)

    return modules


def choose_module(modules):

    chosen_files = []

    for key, val in modules.items():
        click.echo("choose module number:")
        for i in zip(list(range(1, len(val) + 1)), val):
            click.echo(i)
        selection = list(input().split(" "))
        if selection == [""]:
            click.echo()
            continue
        chosen_files += [val[int(i) - 1] for i in selection]
        click.echo()

    return chosen_files


@click.group()
def cli():
    """Simple online solver for the logistics domain."""
    pass


@cli.command()
@click.option(
    "-f",
    "--filename",
    help="Name of output configuration file.",
    default='robosanta.json',
    show_default=True)
def configure(filename):
    """Generate configuration file for robosanta."""

    config = {}
    config['modules'] = choose_module(parse_modules(load_files(".")))

    flag = click.confirm("multishot(incremental) solving?")
    config['incremental-mode'] = flag

    with open(filename, "w") as f:
        json.dump(config, f, indent=4)


@cli.command()
@click.argument("instance")
@click.option('-c', '--config-file', default='robosanta.json')
def solve(instance, config_file):
    """Solve instance with some configuration."""

    with open(config_file) as f:
        config = json.load(f)

    solver = Solver(instance, *config['modules'])
    solver.callSolver(config['incremental-mode'])


if __name__ == "__main__":
    cli()