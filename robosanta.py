from __future__ import print_function
import json
import os
from pathlib import Path
import subprocess

import clingo
import click
from six.moves import input

from tqdm import tqdm

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

        while (self.step < self.imax.number) and (
            self.ret is None
            or (self.istop.string == "SAT" and not self.ret.satisfiable)
        ):

            self.control.assign_external(
                clingo.Function("query", [self.step - 1]), False
            )

            if self.grounded == 0 and self.step == 1:
                self.control.ground(
                    [
                        ("base", []),
                        ("init", []),
                        ("step", [self.step]),
                        ("check", [self.step]),
                    ]
                )
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
                self.control.statistics,
                sort_keys=True,
                indent=4,
                separators=(",", ": "),
            )
        )

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


def call_clingo(file_names, time_limit=60, options=None):

    CLINGO = [
        RUNSOLVER_PATH,
        "-W",
        "{}".format(time_limit),
        "-w",
        "runsolver.watcher",
        "-d",
        "20",
        CLINGO_PATH,
    ] + file_names

    call = CLINGO + ([] if options is None else options)

    print("calling: " + " ".join(call))

    try:
        output = subprocess.check_output(call).decode("utf-8")
    except subprocess.CalledProcessError as e:
        output = e.output.decode("utf-8")

    print("call has finished\n")

    return output


class Solver:
    def __init__(self, instances, encodings, time_limit=60, verbose=True):
        if type(instances) == list:
            self.instance = [str(p) for p in instances]
        else:
            self.instance = [instances]
        self.encodings = encodings
        self.time_limit = time_limit

        self.verbose = verbose

        self.output = None

        self.temp = []

        self.output_facts = ""

    def callSolver(self, multishot=False, stats_output=None, options=None):
        if multishot:
            files = self.instance + self.encodings + ["incremental_python.py"]
        else:
            files = self.instance + self.encodings

        self.solve(files + self.temp, options)
        return self.output_facts

    def solve(self, files, options):
        self.output = call_clingo(files, self.time_limit, options=options)

        self.parse_best_solution(self.output)

    def parse_best_solution(self, output):
        best_solution = ""
        lines = output.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("Answer"):
                best_solution = lines[i + 1]

        self.output_facts = (
            best_solution.replace(" ", ".\n") + "."
        )  # missing dot at the end

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


def split_solver(
    instance,
    stage_one,
    stage_two,
    multishot=False,
    verbose=False,
    time_limit_ta=60,
    time_limit_pf=60,
    options=None,
):
    """
    Solve two times while giving output of first solve to the next one
    :param instance: instance file
    :param stage_one: list with file names for the first solve call
    :param stage_two: list with file names for the second solve call
    """

    printf = print if verbose else lambda *a: None

    output_atoms = ""
    stage_solvers = []
    # only solve TA if there are files in stage one
    if stage_one:
        printf()
        printf("Solving Task Assignment...")
        printf()

        solver1 = Solver(instance, stage_one, verbose=verbose, time_limit=time_limit_ta)
        output_atoms = solver1.callSolver(
            multishot=False, stats_output="stats-TA.json", options=options
        )

        solver1.print_output()

        printf()
        printf("Task Assignment solved, moving on to path finding...")
        printf()
        stage_solvers.append(solver1)

    printf("Starting Pathfinding...")
    solver2 = Solver(instance, stage_two, verbose=verbose, time_limit=time_limit_pf)
    solver2.add_atoms(output_atoms)
    solver2.callSolver(multishot=multishot, options=options)

    solver2.print_output()

    printf()
    printf("Path finding solving is done!")
    stage_solvers.append(solver2)
    return stage_solvers


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
    default="robosanta.json",
    show_default=True,
)
def configure(filename):
    """Generate configuration file for robosanta."""

    config = {}
    config["modules_stage_one"], config["modules_stage_two"] = choose_modules(
        parse_modules(load_files("./encodings"))
    )

    flag = click.confirm("multishot(incremental) solving?")
    config["incremental-mode"] = flag

    with open(filename, "w") as f:
        json.dump(config, f, indent=4)


@cli.command()
@click.argument("instance")
# To pass clingo options specify all the arguments then type a space followed by "--".
# Then another space and then whatever clingo options you would like to pass
@click.argument("clingo_options", nargs=-1)
@click.option("-c", "--config-file", default="robosanta.json")
@click.option("-v", "--verbose", is_flag=True, default=False)
@click.option("-t", "--time-limit-ta", default=60, type=int)
@click.option("-t", "--time-limit-pf", default=60, type=int)
def solve(instance, clingo_options, config_file, verbose, time_limit_ta, time_limit_pf):
    """Solve instance with some configuration."""

    with open(config_file) as f:
        config = json.load(f)
    split_solver(
        instance,
        config["modules_stage_one"],
        config["modules_stage_two"],
        multishot=config["incremental-mode"],
        verbose=verbose,
        time_limit_ta=time_limit_ta,
        time_limit_pf=time_limit_pf,
        options=list(clingo_options),
    )


@cli.command()
@click.argument("config_path")
@click.argument("instances_dir")
@click.argument("stats_dir")
@click.argument("extend_horizon", default=0, type=int)
# To pass clingo options specify all the arguments then type a space followed by "--".
# Then another space and then whatever clingo options you would like to pass
@click.argument("clingo_options", nargs=-1)
def experiment(config_path, instances_dir, stats_dir, extend_horizon, clingo_options):
    """Run some experiments and record the stats."""

    stats_dir = Path(stats_dir)
    stats_dir.mkdir(parents=True, exist_ok=True)

    horizon_option_present = any("horizon" in option for option in clingo_options)

    def get_horizon(filename):
        with open(filename, "r") as f:
            data = f.readline()
            return int(''.join(filter(str.isdigit, data)))

    print(len(list(Path(instances_dir).rglob("*.lp"))))
    for instance_path in tqdm(list(Path(instances_dir).rglob("*.lp"))):
        # For reference on how asprilo instances_dir are structured:
        # https://github.com/potassco/asprilo/blob/master/docs/experiments.md#minimal-horizon-and-task-assignment
        # This is the instance itself.
        instance_facts = [instance_path]
        if not horizon_option_present:
            # This is the corresponding minimal horizon.
            # Passing a horizon globally as a clingo option will override this.
            if os.path.isfile(instance_path.with_suffix(".lp__hor-a")):
                horizon = get_horizon(instance_path.with_suffix(".lp__hor-a"))
            elif os.path.isfile(instance_path.with_suffix(".lp__hor-aa")):
                horizon = get_horizon(instance_path.with_suffix(".lp__hor-aa"))
            else:
                print("Horizon file does not exist!")
                raise SystemExit
            # TODO: sensible if statement for extending the horizon
            if extend_horizon != 0:
                print("Extending horizon by {}".format(extend_horizon))
            horizon += extend_horizon

        # Using tqdm instead of printing keeps the progress bar uninterrupted.
        tqdm.write(f"Solving instance: {instance_path.stem}")
        with open(config_path) as f:
            config = json.load(f)

        clingo_options = list(clingo_options)
        if not horizon_option_present:
            clingo_options_final = clingo_options + [f"-c horizon={horizon}"]

        solvers = split_solver(
            instance_facts,
            config["modules_stage_one"],
            config["modules_stage_two"],
            verbose=True,
            time_limit_ta=300,
            time_limit_pf=1800,
            options=clingo_options_final,
        )
        tqdm.write("Finished")
        for solver, part in zip(solvers, ["pt1", "pt2"]):
            stats_path = stats_dir / instance_path.with_suffix(f".{part}.stats").name
            with stats_path.open("w") as stats_file:
                # For now this writes whole output without parsing anything.
                stats_file.write(solver.output)
            tqdm.write(f"Done writing to {stats_path}")


if __name__ == "__main__":
    cli()
