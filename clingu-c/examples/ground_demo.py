#!/usr/bin/env python3
"""
How `&cumu` grounds -- a runnable illustration.

This shows, with plain clingo (no clingcon needed), exactly how gringo grounds a
`&cumu`-shaped theory atom into elements, and why the propagator MUST look at each
element's condition literal.

A theory element `Tuple : Condition` grounds to:
  * one element per satisfying instantiation of the Condition's variables,
  * with the tuple terms evaluated to ground theory terms, and
  * a condition literal (or no condition at all, if it was true at ground time).

We use an inline `#theory` whose element shape matches clingcon's `&cumu`
(`sum_term, {<=}, sum_term, any`). clingcon skips `rewrite_tuple` for `&cumu`, so
the tuple is grounded exactly as written -- which is what this script reproduces.

Run:
    python3 ground_demo.py

Key takeaways printed below:
  * CHOICE-generated flights with a `_` payload wildcard  -> MANY elements that
    share one start variable but carry DISTINCT condition literals (one per W).
    Counting all of them is the over-report bug; the fix gates on the condition.
  * FACT flights -> the condition is simplified away (empty / always true), so
    there is exactly one element per flight. This is why the original,
    condition-ignoring propagator looked correct on facts but broke on choices.
"""

import clingo

# Element shape matches clingcon's `&cumu`: a tuple term, a `<=` guard, head-or-body.
THEORY = r"""
#theory cumu {
    cterm {
        -  : 3, unary;
        *  : 2, binary, left;
        +  : 1, binary, left
    };
    &cumu/0 : cterm, {<=}, cterm, any
}.
"""


def dump(title, program):
    print("=" * 72)
    print(title)
    print("=" * 72)
    ctl = clingo.Control()
    ctl.add("base", [], THEORY + program)
    ctl.ground([("base", [])])
    for ta in ctl.theory_atoms:
        print(f"  &{ta.term}  (guard: {ta.guard[0]} {ta.guard[1]})")
        print(f"  # grounded elements: {len(ta.elements)}")
        for el in ta.elements:
            tup = [str(t) for t in el.terms]
            cond = list(el.condition)
            note = "  <- condition simplified away (always true)" if not cond else ""
            print(f"    tuple={tup}  condition_id={el.condition_id}  condition_lits={cond}{note}")
    print()


# ---- 1) choice-generated flights (the realistic eVTOL case) ----------------
# Segment 1: choose exactly one edge out of `a`, carrying W customers (W in 0..2,
# mimicking the `0..C` payload in `1 {flight(D,E,0..C,X):edge(E)} 1`). The &cumu
# condition uses `_` for W, so every W value spawns a separate element.
dump(
    "CHOICE-generated flights: `flight((a,V),W,1)` with a `_` payload wildcard",
    r"""
vertiport(a;b;c).
1 { flight((a,V),W,1) : vertiport(V), W=0..2 } 1.
&cumu{ takeoff((U,V),1), 15, 1 : flight((U,V),_,1) } <= 4.
""",
)

# ---- 2) the same &cumu, but flights given as FACTS -------------------------
dump(
    "FACT flights: condition is true at ground time, so it is dropped",
    r"""
flight((a,b),2,1).
flight((a,c),0,1).
&cumu{ takeoff((U,V),1), 15, 1 : flight((U,V),_,1) } <= 4.
""",
)

print("Notice in case 1 that e.g. `takeoff((a,b),1)` appears once per W value --")
print("same tuple / same start variable, but a DISTINCT condition literal each time.")
print("gringo keeps elements distinct by (tuple, condition) and does not merge them,")
print("so the propagator counts a copy as a task only when its condition literal is")
print("true (see src/cumulative.cc, the `active(o)` gate). Without that gate, one")
print("real flight would be counted (capacity+1) times.")
