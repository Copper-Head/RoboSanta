import clingo
import argparse
import json


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
        print "Solving..."
        self.ret = None

        while (self.step < self.imax.number) and\
                (self.ret is None or (self.istop.string == "SAT" and not self.ret.satisfiable)):

            self.control.assign_external(clingo.Function("query", [self.step-1]), False)

            if self.grounded == 0 and self.step == 1:
                self.control.ground([("base", []), ("init", []), ("step", [self.step]), ("check", [self.step])])
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
        print "Model found"
        self.solved = True
   
        for atom in model.symbols(shown=True):
            print atom
    
    def stats(self):
        statistics = json.loads(json.dumps(self.control.statistics, sort_keys=True, indent=4, separators=(',', ': ')))

        self.solvetime = statistics["summary"]["times"]["solve"]
        self.groundtime = statistics["summary"]["times"]["total"] - self.solvetime

        print "solve time: ", self.solvetime
        print "ground time:", self.groundtime

    def callSolver(self, multishot=False):
        if multishot:
            self.solve_incremental()
        else:
            self.solve_normal()
        self.stats()
        print "Solved: ", self.solved



def main():
    
    parser = argparse.ArgumentParser(description="Simple online solver for the logistics domain")

    parser.add_argument("-i", "--instance", help="Instance to solve", required=True)
    parser.add_argument("-e", "--encoding", help="encoding(s) for the logistics domain", nargs="+", required=True)
    parser.add_argument("-m", "--multishot", help="Flag to enable multishot(incremental) solving", action="store_true")

    args = parser.parse_args()


    instance = args.instance
    encoding = args.encoding
    multi = args.multishot

    solver = Solver(instance, *encoding)
    solver.callSolver(multi)

if __name__ == "__main__":
    main()




