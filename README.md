# RoboSanta
Make sure all kids big and small get their presents on time!
A multi-agent logistics planner that uses [Answer Set Programming](https://en.wikipedia.org/wiki/Answer_set_programming).

## Setup/Installation
The most convenient way to set things up is to use conda to recreate the environment:
```
conda env create -n robosanta -f environment.yaml
```

With the environment activated, install RoboSanta using `pip`:
```
pip install --editable .
```
This will install all the dependencies of this script *except pyclingo*, which should have been installed by `conda`.
Moreover it will add a `robosanta` command to your PATH.
To find out what it does simply run:
```
robosanta
```

You can also run the script directly (provided you installed the dependencies manually):
```
python robosanta.py
```
