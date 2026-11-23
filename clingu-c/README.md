# clingu-c: the `&cumu` propagator

This folder holds the implementation of the `cumulative` constraint that turns
[clingcon](https://github.com/potassco/clingcon) into clingu: two source files,
a patch that connects them to clingcon, a build script and examples.
For installation and a first example, start with the
[top-level README](../README.md); this document is the reference.

The propagator is built on clingcon's own machinery. It uses clingcon's integer
variables and their order literals `[s <= k]`, and it explains every inference
with a clause over those literals. Conflict analysis therefore combines
`&cumu` clauses with those of `&sum` and of the rest of the program without any
extra mechanism.

Current version: **v3.1**.

## Contents

```
clingu-c/
├── clingcon/cumulative.hh    constraint class      -> libclingcon/clingcon/
├── src/cumulative.cc         propagator            -> libclingcon/src/
├── clingcon-wiring.patch     changes to six clingcon files (git apply)
├── build_clingu.sh           fetch clingcon, patch, build, check
├── LICENSE.clingcon          clingcon's MIT licence (the patch quotes its sources)
└── examples/
    ├── tasks.lp              three tasks on one resource, minimal example
    ├── solve.py              the same example through the Python API
    ├── evtol.lp              eVTOL fleet scheduling with vertiport capacity
    ├── evtol_presolve.lp     variant of evtol.lp for a presolve step
    ├── tiny_3v3a_sat.lp      hand-checkable satisfiable instance
    ├── tiny_3v3a_unsat.lp    hand-checkable unsatisfiable instance
    ├── network-ny_0_pax6_...lp small eVTOL instance, horizon 60
    └── ground_demo.py        shows how a &cumu atom is grounded
```

## Building

```bash
bash build_clingu.sh
```

The script installs clingo 5.8.0, CMake, Ninja and scikit-build with `pip`,
clones clingcon at a pinned commit (version 5.2.1), copies the two source files
in, applies the patch, builds the Python module and runs a smoke test. Linux only.

| Variable | Default | Meaning |
|----------|---------|---------|
| `WORK` | `~/clingu-build` | Build directory. It is deleted and recreated on every run. |
| `PY` | `python3` | Interpreter to build for. The module works only with this interpreter. |
| `CLINGU_CXX_FLAGS` | empty | Extra compiler flags; see Compile-time options. |

Run a program with the interpreter the build reported:

```bash
PYTHONPATH=~/clingu-build/clingcon/libpyclingcon python3 -m clingcon PROGRAM.lp -t 1 --sat-prepro=no
```

The script builds the Python module. To build clingcon's standalone binary
instead, install the clingo development package (for example
`conda install -c potassco/label/dev -c conda-forge clingo ninja cmake cxx-compiler`)
and run CMake on the patched tree in the usual way.

## Syntax

```asp
&cumu{ Start,Duration,Demand : Condition ; ... } <= Capacity.
```

Each element is a task: it starts at the integer variable `Start`, occupies
`[Start, Start + Duration)` and uses `Demand` units. The constraint holds when,
at every instant, the demands of the present tasks sum to at most `Capacity`.

- **The start variable is the first term of the tuple.** Everything after the
  colon is a condition, not part of the task. In the eVTOL encoding:

  ```asp
  &cumu{ takeoff(D,(V,Vp),X), window_length, 1 : flight(D,(V,Vp),_,X);
         landing(D,(Vp,V),X), window_length, 1 : flight(D,(Vp,V),_,X) } <= C :- vertiport_cap(V,C).
  ```

  `takeoff(D,(V,Vp),X)` is the same integer variable that `&dom` and `&sum` use.
- **`&cumu` is the head of a fact.** A rule body is accepted when it consists of
  facts after grounding, as with `vertiport_cap/2` above. A `&cumu` atom in a
  rule body, or a head whose body is not a fact, is rejected when the program
  is loaded.
- **Duration, demand and capacity are non-negative integers.** Zero is allowed.
  A negative value is a syntax error.
- **The start is an integer variable.** A number, a string, a negated term or an
  arithmetic expression is a syntax error.
- **Conditions.** A task is present only when its condition holds. Elements
  follow clingo's semantics for theory atoms: two elements with the same tuple
  and the same condition are one task; with the same tuple and different
  conditions they are two tasks when both conditions hold.

## Solver options

- **`--sat-prepro=no` is required.** With SAT preprocessing, this build can
  report a model before every integer variable has a value, also for programs
  without `&cumu`.
  The clasp configurations `jumpy`, `handy`, `crafty` and `trendy` enable
  preprocessing, so the option has to follow them on the command line.
- **Use one solver thread (`-t 1`).**
- **`--cumu-explanation=<form>`** selects the form of the learned clauses; see
  the next section. From Python:
  `theory.configure("cumu-explanation", "naive")` after `theory.register(ctl)`.

With `--stats=2` the solver reports, per thread, the number of clauses the
propagator produced: `Cumulative conflict clauses`, `Cumulative push clauses`
and `Cumulative presence clauses`.

## Explanation forms

Every clause the propagator emits says: if these tasks start within these
ranges, then an overload follows, or a bound of another task follows. The form
decides how wide the ranges are.

| Form | Range required of each task in the clause |
|------|-------------------------------------------|
| `pointwise` (default) | The task covers one instant `t`: start in `[t-d+1, t]`. |
| `bigstep` | The task covers a whole step `[l, r)` of the profile: start in `[r-d, l]`. A push moves the start past the step at once. |
| `naive` | The task keeps its current bounds. |
| `mixed` | `pointwise` for overloads, `bigstep` for bound pushes. |

All four are entailed by the constraint and give the same answer sets. They
differ in how general the learned clauses are, and so in how the search
proceeds; which one finds the best solution in a fixed time depends on the
problem.

On the eVTOL benchmark (90 instances, three solver seeds, 300 s, v3.1) `naive`
found the highest revenue. It was alone in front on 111 of the 270 runs, against
26 for `bigstep`, 20 for `pointwise` and 19 for `mixed`, with 94 ties, and its
total revenue was 29% above that of `pointwise`. The other three forms were
close to each other. For models of this kind, try `naive` first.

## Compile-time options

Pass these through `CLINGU_CXX_FLAGS`, for example
`CLINGU_CXX_FLAGS="-DCLINGU_F4" bash build_clingu.sh`.

| Flag | Effect |
|------|--------|
| `-DCLINGU_F4` | Presence propagation: a conditional task that is not yet decided and whose compulsory part does not fit has its condition set to false. Sound, but it slowed the search on the eVTOL benchmark, so it is off by default. |
| `-DCLINGU_FULL_WITNESS` | Put every task that covers the instant into a clause, not a minimal subset. For comparison only. |
| `-DCLINGU_NAIVE_OWN_LITERAL` | Explain a push with the pushed task's current bound, as version 1 did. |

## How it works

The propagator is a time-table propagator. On each call it:

1. **Builds the profile.** A task whose latest start `ub` is before its earliest
   end `lb + d` certainly runs on `[ub, lb + d)`, its compulsory part. A sweep
   over the start and end events of the compulsory parts gives the resource
   usage at every instant in `O(n log n)`.
2. **Detects overloads.** If the usage exceeds the capacity at some instant, it
   emits a conflict clause over a minimal set of the tasks that cover it.
3. **Pushes bounds.** If a task cannot run at some instant of its window
   without exceeding the capacity, its earliest start is moved past that
   instant, or its latest start before it. The new bound goes back to clingcon,
   so `&sum` constraints see it, and the propagator is called again until
   nothing changes.

**Conditional tasks.** For each conditional element the propagator creates an
auxiliary integer variable that is positive exactly when the condition holds,
and watches it. A task takes part in the profile only when its condition is
true, and the condition literal is part of every clause that relies on the
task. The auxiliary variable is needed because clingcon watches integer
variables, not condition literals: without it, a condition that becomes true
late in the search would not wake the propagator.

**Explanation literals.** clingcon creates order literals on demand and leaves
a new one unassigned. Before a clause uses a literal at a value that is not a
current bound, the propagator links it to the bound literal that implies it, so
that the clause takes effect immediately.

**Final check.** When clingcon reports a total assignment, `check_full()`
recomputes the profile from the assigned start times and raises an error if the
capacity is exceeded. On a correctly propagated model it never fires.

| Concept | Code in `src/cumulative.cc` |
|---------|------------------------------|
| start variable and its bounds | `solver.var_state(var)`, `lower_bound()`, `upper_bound()` |
| order literal `[s <= k]` | `solver.get_literal(cc, vs, k)` |
| compulsory parts and profile | `propagate()` |
| overload clause | `add_conflict()` |
| range of start values per form | `cover_lits()` |
| bound push | `push_bound()` |
| presence propagation (`-DCLINGU_F4`) | `push_presence()` |
| literals linked to the bounds | `le_true()`, `le_false()` |
| activity variable of a conditional task | `translate()` |
| final check | `check_full()` |

## Integration with clingcon

`clingcon-wiring.patch` changes six files of clingcon:

| File | Change |
|------|--------|
| `libclingcon/CMakeLists.txt` | Adds the two new files to the build. |
| `base.hh` | Three per-thread clause counters; the `CumuExplanation` enumeration and its field in `Config`. |
| `clingcon.cc` | The option `--cumu-explanation` and the matching `configure` key; the assignment of a model lists named variables only. |
| `parsing.hh` | The theory atoms `&__cumu_h` and `&__cumu_b` in the grammar; the `add_cumulative` builder function. |
| `parsing.cc` | `parse_cumulative`, which reads the elements, their conditions and the capacity and validates them; the rewriting of `&cumu` into the head and body forms. |
| `propagator.cc` | The `add_cumulative` implementation, which also enforces the fact-head rule; the counters in the statistics. |

`&cumu` tuples have three terms, so the AST rewriting handles them in a branch
of their own instead of clingcon's helper for single-term tuples. The same
rewriting is what allows the capacity to come from a fact in the rule body, as
for `&sum`.

## Design note: minimal witness sets

In a clause-learning solver the propagator does not backtrack; it emits a
clause and the solver's conflict analysis decides how far to jump back. The
propagator influences this only through how general its clauses are.

An overload at instant `t` needs only enough covering tasks for their demands
to exceed the capacity, so the propagator stops collecting tasks as soon as
they do. Measured with version 1 on eVTOL instances (single thread):

| Run | All covering tasks | Minimal set |
|-----|--------------------|-------------|
| Unsatisfiability proof, instance 0, capacity 2 | 374 conflicts, 0.11 s | 400 conflicts, 0.07 s |
| Unsatisfiability proof, instance 1, capacity 2 | 1,142 conflicts, 0.31 s | 257 conflicts, 0.04 s |
| Unsatisfiability proof, instance 2, capacity 2 | 245 conflicts, 0.02 s | 245 conflicts, 0.02 s |
| Optimisation, 20 s, instance 0, capacity 4 | 1,708,919 choices | 1,570,420 choices, same objective |
| Optimisation, 20 s, instance 0, capacity 5 | 1,367,062 choices | 1,336,769 choices, same objective |

The two coincide when an overload has exactly enough covering tasks, and the
minimal set helps when it has more. Build with `-DCLINGU_FULL_WITNESS` to
compare.

The explanation forms above follow the classification of Schutt, Feydy, Stuckey
and Wallace, *Explaining the cumulative propagator* (Constraints, 2011).
