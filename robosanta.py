from __future__ import print_function
import json
import os
import subprocess

import clingo
import click
from six.moves import input

RUNSOLVER_PATH = "." + os.sep + "runsolver"


def _determine_clingo_path():
    """A quick hack to have clingo work everywhere.

    Ilia's computer is a victim of the compatibility war between
    pyenv and conda so virtualenvs managed by the latter are messed up.
    To address that there's a local symlink to the correct clingo version
    in his repo.
    For everyone else the normal clingo invocation should work.
    This function adjusts the clingo path depending on the hostname
    of the machine the script is running on.
    Socket module is imported in the function because we don't need it
    anywhere else.
    """
    import socket
    if socket.gethostname() == "fangorn":
        return "." + os.sep + "clingo"
    return "clingo"


CLINGO_PATH = _determine_clingo_path()


class Solver_python(object):

    def __init__(self, instance, encodings, verbose=True):

        self.verbose = verbose

        self.control = clingo.Control()

        self.control.load(str(instance))
        for e in encodings:
            self.control.load(str(e))

        self.imax = self.get(self.control.get_const("imax"), clingo.Number(100))
        self.istop = self.get(self.control.get_const("istop"), clingo.String("SAT"))

        self.step, self.ret = 1, None
        self.grounded = 0

        self.solved = False

        self.shown_atoms = []

    @staticmethod
    def get(val, default):
        return val if val != None else default

    def add_atoms(self, atoms=[]):
        # atoms is a list of atoms in string form
        for atom in atoms:
            self.control.add("base", [], atom + ".")

    def solve_incremental(self):
        print("Solving...")
        self.solved = False
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
        self.solved = False
        self.control.ground([("base", []), ("init", [])])
        self.control.solve(on_model=self.on_model)

    def on_model(self, model):
        self._print("Model found")
        self.solved = True

        self.shown_atoms = []
        for atom in model.symbols(shown=True):
            self.shown_atoms.append(str(atom))

    def stats(self, output_name=None):
        statistics = json.loads(
            json.dumps(
                self.control.statistics, sort_keys=True, indent=4, separators=(',', ': ')))

        self.solvetime = statistics["summary"]["times"]["solve"]
        self.groundtime = statistics["summary"]["times"]["total"] - self.solvetime

        self._print("solve time: ", self.solvetime)
        self._print("ground time:", self.groundtime)

        if output_name is not None:
            with open(output_name, "w") as f:
                json.dump(statistics, f, indent=4)

    def callSolver(self, multishot=False, stats_output=None):
        if multishot:
            self.solve_incremental()
        else:
            self.solve_normal()
        self.stats(stats_output)
        self._print("Solved: ", self.solved)
        return self.shown_atoms

    def print_output(self):
        if self.solved:
            for atom in sorted(self.shown_atoms):
                print(atom)
        else:
            print("No output to print")

    def _print(self, *print_args):
        if self.verbose:
            print(*print_args)
        

def call_clingo(file_names, time_limit=60, options=[]):

    CLINGO = [RUNSOLVER_PATH, "-W", "{}".format(time_limit), \
              "-w", "runsolver.watcher", "-d", "20", 
              CLINGO_PATH] + file_names

    call = CLINGO + options

    print("calling: " + " ".join(call))

    try:
        output = subprocess.check_output(call).decode("utf-8")
    except subprocess.CalledProcessError as e:
        output = e.output.decode("utf-8")

    print("call has finished\n")
        
    return output


class Solver:

    def __init__(self, instance, encodings, time_limit=60, verbose=True):
        self.instance = list(instance)
        self.encodings = encodings
        self.time_limit = time_limit
        
        self.verbose = verbose
        
        self.output = None

        self.temp = []

        self.output_facts = ""
    
    def callSolver(self, multishot=False, stats_output=None):
        if multishot:
            files = self.instance + self.encodings + ["incremental_python.py"]
        else:
            files = self.instance + self.encodings

        self.solve(files + self.temp)
        return self.output_facts
                
    def solve(self, files):
        self.output = call_clingo(files, self.time_limit)
        
        self.parse_best_solution(self.output)
        
    def parse_best_solution(self, output):
        best_solution = ""
        lines = output.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("Answer"):
                best_solution = lines[i+1]

        self.output_facts = best_solution.replace(" ", ".\n") + "."#missing dot at the end

        
    def _print(self, *print_args):
        if self.verbose:
            print(*print_args)

    def add_atoms(self, atom_str):
        if atom_str == "":
            return 0

        temp_name = "temp.lp"
        with open(temp_name, "w") as f:
            f.write(atom_str)

        self.temp += [temp_name]

    def print_output(self):
        print(self.output)
    
def split_solver(instance, stage_one, stage_two, multishot=False, verbose=False, time_limit_ta=60, time_limit_pf=60):
    """
    Solve two times while giving output of first solve to the next one
    :param instance: instance file
    :param stage_one: list with file names for the first solve call
    :param stage_two: list with file names for the second solve call
    """

    printf = print if verbose else lambda *a: None

    output_atoms = ""
    # only solve TA if there are files in stage one
    if len(stage_one) > 0:
        printf()
        printf("Solving Task Assignment...")
        printf()

        solver1 = Solver(instance, stage_one, verbose=verbose, time_limit=time_limit_ta)
        output_atoms = solver1.callSolver(multishot=False, stats_output="stats-TA.json")

        solver1.print_output()

        printf()
        printf("Task Assignment solved, moving on to path finding...")
        printf()


    printf("Starting Pathfinding...")
    solver2 = Solver(instance, stage_two, verbose=verbose, time_limit=time_limit_pf)
    solver2.add_atoms(output_atoms)
    solver2.callSolver(multishot=multishot)

    solver2.print_output()

    printf()
    printf("Path finding solving is done!")
    #return solver1, solver2


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
        module_name = module_name.split(os.sep)[-1]
        if module_name not in modules:
            modules[module_name] = []

        modules[module_name].append(file_)

    return modules


def choose_modules(modules):

    # module name for the files that go into the TA phase (stage one for solving)
    identifier_TA = "TA"

    chosen_files_stage_one = []
    chosen_files_stage_two = []

    for key, val in modules.items():
        click.echo("choose module number:")
        for i in zip(list(range(1, len(val) + 1)), val):
            click.echo(i)
        selection = list(input().strip().split(" "))
        if selection == [""]:
            click.echo()
            continue

        # TODO: here we hardcode which files go into the first solve and which to the second. Maybe ask user for this?
        if key == identifier_TA:
            chosen_files_stage_one += [val[int(i) - 1] for i in selection]
        else:
            chosen_files_stage_two += [val[int(i) - 1] for i in selection]

        click.echo()

    return chosen_files_stage_one, chosen_files_stage_two


@click.group()
def cli():
    """Simple online solver for the logistics domain."""


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
    config['modules_stage_one'], config['modules_stage_two'] = choose_modules(
        parse_modules(load_files("./encodings")))

    flag = click.confirm("multishot(incremental) solving?")
    config['incremental-mode'] = flag

    with open(filename, "w") as f:
        json.dump(config, f, indent=4)


@cli.command()
@click.argument("instance", nargs=-1)
@click.option('-c', '--config-file', default='robosanta.json')
@click.option('-v', '--verbose', is_flag=True, default=False)
@click.option('-t', '--time-limit-ta', default=60, type=int)
@click.option('-t', '--time-limit-pf', default=60, type=int)

def solve(instance, config_file, verbose, time_limit_ta, time_limit_pf):
    """Solve instance with some configuration."""

    with open(config_file) as f:
        config = json.load(f)
    split_solver(instance, config['modules_stage_one'], config['modules_stage_two'],
                 multishot=config['incremental-mode'], verbose=verbose, 
                 time_limit_ta=time_limit_ta, time_limit_pf=time_limit_pf)


if __name__ == "__main__":
    cli()
