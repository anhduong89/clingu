# clingu

**clingu** is [clingcon](https://github.com/potassco/clingcon) extended with a
`cumulative` global constraint, written `&cumu`. It lets an answer set program
with integer variables state that tasks sharing a resource never exceed its
capacity, and enforces this with a dedicated time-table propagator instead of
a time-indexed encoding.

```asp
&cumu{ s(T),D,R : task(T,D,R) } <= 3.
```

Every task `T` starts at the integer variable `s(T)`, runs for `D` time units
and uses `R` units of the resource; at every instant the running tasks use at
most 3 units.

## Features

- **Native cumulative constraint.** The constraint is not expanded over time
  points, so its ground size does not depend on the scheduling horizon.
- **Works with the rest of clingcon.** `&cumu` uses the same integer variables
  as `&dom`, `&sum` and `&minimize`, and the clauses it learns combine with those
  of the other constraints.
- **Optional tasks.** An element may carry a condition; the task counts only when
  the condition holds.
- **Overload detection and bound propagation** on the time-table profile, with
  four selectable forms of explanation clause.
- **Python and command-line use,** as with clingcon.

## Requirements

- Linux
- Python 3 with `pip`, a C++17 compiler, and `git`
- The build script installs clingo 5.8.0, CMake and Ninja with `pip`, and
  fetches clingcon 5.2.1 at a pinned commit.

## Installation

```bash
git clone https://github.com/anhduong89/clingu.git
cd clingu/clingu-c
bash build_clingu.sh
```

The script builds into `~/clingu-build` (set `WORK` to change this, `PY` to choose
the Python interpreter) and finishes with a short check that the constraint
is active. The
compiled module works only with the interpreter it was built for; the script
prints which one that is.

## Quick start

[`clingu-c/examples/tasks.lp`](clingu-c/examples/tasks.lp) schedules three tasks
on a resource of capacity 3 and minimises the makespan:

```asp
task(a,4,2). task(b,3,1). task(c,3,2).        % task(Name, Duration, Demand)

&dom{0..10} = s(T) :- task(T,_,_).
&cumu{ s(T),D,R : task(T,D,R) } <= 3.

&dom{0..13} = makespan.
&sum{ s(T) } <= makespan - D :- task(T,D,_).
&minimize{ makespan }.
```

Run it with the Python the build used:

```bash
PYTHONPATH=~/clingu-build/clingcon/libpyclingcon python3 -m clingcon clingu-c/examples/tasks.lp 0 -t 1 --sat-prepro=no
```

```
Assignment:
makespan=7 s(a)=3 s(b)=0 s(c)=0
Cost: 7
```

Tasks `a` and `c` together would need 4 units, so they run one after the other;
`b` fits beside either.

### From Python

[`clingu-c/examples/solve.py`](clingu-c/examples/solve.py):

```python
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
```

```bash
PYTHONPATH=~/clingu-build/clingcon/libpyclingcon python3 clingu-c/examples/solve.py clingu-c/examples/tasks.lp
```

## The `&cumu` constraint

```asp
&cumu{ Start,Duration,Demand : Condition ; ... } <= Capacity.
```

| Part | Meaning |
|------|---------|
| `Start` | An integer variable, the same one `&dom` and `&sum` refer to. |
| `Duration` | A non-negative integer. The task occupies `[Start, Start + Duration)`. |
| `Demand` | A non-negative integer, the amount of the resource the task uses. |
| `Condition` | Optional. The task is present only when the condition holds. |
| `Capacity` | A non-negative integer. |

Rules of use:

- `&cumu` is the head of a fact. A rule body is allowed when it consists of
  facts, as in `&cumu{ ... } <= C :- capacity(R,C).`
- The start variable comes first in the tuple, before the colon. Everything
  after the colon is a condition.
- A start term that is not a variable, and a negative duration, demand or
  capacity, are reported as syntax errors.
- Two elements with the same tuple and the same condition are one task.

### Solver options

| Option | Purpose |
|--------|---------|
| `--sat-prepro=no` | **Required.** With SAT preprocessing this build can lose answers or report incomplete ones. The clasp configurations `jumpy`, `handy`, `crafty` and `trendy` switch preprocessing on, so give this option after them. |
| `-t 1` | Use one solver thread. |
| `--cumu-explanation=<form>` | Form of the learned clauses: `pointwise` (default), `bigstep`, `naive` or `mixed`. All four give the same answers and differ only in search behaviour. On our eVTOL benchmark `naive` found the best schedules; details in [`clingu-c/README.md`](clingu-c/README.md). |

The solver statistics (`--stats=2`) report how many clauses the propagator
produced.

## Repository layout

| Path | Contents |
|------|----------|
| [`clingu-c/`](clingu-c/) | The propagator (`src/cumulative.cc`, `clingcon/cumulative.hh`), the patch that connects it to clingcon, the build script and examples. Its [README](clingu-c/README.md) documents the implementation. |
| [`utils/`](utils/) | A run harness (`solver.py`) and an independent schedule checker (`check_schedule.py`) for the eVTOL application. |
| [`exp/instances/`](exp/instances/) | 120 synthetic eVTOL fleet-scheduling instances. |
| [`instances/`](instances/) | A synthetic energy-cost data set; see [its README](instances/README.md). |

## Versions

The current propagator is **v3.1**. It includes a correction of November 2026
that affects all earlier versions; use v3.1 or later for new work.

## License

MIT; see [LICENSE](LICENSE). Copyright (c) 2026 New Mexico State University.

clingcon (MIT, Copyright 2017 Roland Kaminski) is not redistributed here; the
build script fetches it from upstream. Its licence is reproduced in
[`clingu-c/LICENSE.clingcon`](clingu-c/LICENSE.clingcon) because
`clingcon-wiring.patch` contains short excerpts of its sources. See
[NOTICE](NOTICE).
