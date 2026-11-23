import sys
from clingo import Control, ast
from clingcon import ClingconTheory

theory = ClingconTheory()
ctl = Control(["-t", "1", "--sat-prepro=no"])
theory.register(ctl)
theory.configure("cumu-explanation", "naive")      # optional; default is pointwise

with ast.ProgramBuilder(ctl) as builder:
    ast.parse_files([sys.argv[1]], lambda stm: theory.rewrite_ast(stm, builder.add))

ctl.ground([("base", [])])
theory.prepare(ctl)

def on_model(model):
    theory.on_model(model)
    starts = {str(name): value for name, value in theory.assignment(model.thread_id)}
    print(starts)

ctl.solve(on_model=on_model)
