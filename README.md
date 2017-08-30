# RoboSanta
Make sure all kids big and small get their presents on time!
A multi-agent logistics planner that uses [Answer Set Programming](https://en.wikipedia.org/wiki/Answer_set_programming).

## Setup/Installation
The most convenient method to set things up is to run the following command
inside a virtual env of some sort:
```
pip install --editable .
```
This will install all the dependencies of this script *except pyclingo*.
Moreover it will add a `robosanta` command to your PATH.
To find out what it does simply run:
```
robosanta --help
```

You can also run the script directly (provided you installed the dependencies manually):
```
python robosanta.py --help
```
