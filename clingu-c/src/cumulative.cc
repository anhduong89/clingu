// libclingcon/src/cumulative.cc
//
// Copyright (c) 2026 New Mexico State University
// SPDX-License-Identifier: MIT
//
// Original work. Written against clingcon's public C++ interface so that it
// compiles inside clingcon's libclingcon/ tree; no clingcon source is copied
// here. clingcon itself is fetched at build time -- see ../../NOTICE.
//
// Thread-specific state + time-table propagator for the cumulative constraint.
//
// Bookkeeping (mark_todo / inactive_level / copy / removable) implements the
// AbstractConstraintState interface. The substantive reasoning is in
// propagate(): compulsory-part profile -> overload detection -> pointwise
// explanation, emitted with cc.add_clause() over clingcon order literals.
//
// The propagator performs, all with pointwise explanations over clingcon order
// literals:
//   - overload detection via an O(n log n) compulsory-part event sweep (F1);
//   - time-table bound pushing (tighten earliest/latest starts), fed back into
//     the &sum bounds, reaching a joint fixpoint over clingcon's re-calls (F2/F3);
//   - presence propagation: an undecided element whose compulsory part is
//     blocked has its condition inferred false (F4; optional, -DCLINGU_F4,
//     off by default).
//
// Explanation form. A clause requires each task in it to start in some range.
// Four forms are available, selected at run time with --cumu-explanation:
//   - pointwise (default): the task covers one instant t, s in [t-d+1, t];
//   - bigstep: the task covers a whole step [l, r) of the profile, s in [r-d, l];
//   - naive: the task keeps its current bounds;
//   - mixed: pointwise for overloads, bigstep for bound pushes.
// All four are entailed by the constraint; pointwise is the most general.

#include <clingcon/cumulative.hh>

#include <algorithm>
#include <cassert>
#include <memory>
#include <stdexcept>
#include <utility>
#include <vector>

namespace Clingcon {

namespace {

class CumulativeConstraintState final : public AbstractConstraintState {
  public:
    explicit CumulativeConstraintState(CumulativeConstraint &constraint) : constraint_{constraint} {}

    // The base copy ctor is deleted, so default-construct it and copy members.
    CumulativeConstraintState(CumulativeConstraintState const &x)
        : AbstractConstraintState(), constraint_{x.constraint_}, todo_{x.todo_}, inactive_level_{x.inactive_level_} {}

    CumulativeConstraintState(CumulativeConstraintState &&) = delete;
    auto operator=(CumulativeConstraintState const &) -> CumulativeConstraintState & = delete;
    auto operator=(CumulativeConstraintState &&) -> CumulativeConstraintState & = delete;
    ~CumulativeConstraintState() override = default;

    // ---- identity / lifecycle ------------------------------------------------
    auto constraint() -> AbstractConstraint & override { return constraint_; }

    [[nodiscard]] auto copy() const -> UniqueConstraintState override {
        return std::make_unique<CumulativeConstraintState>(*this);
    }

    // No eager translation: the constraint stays a lazy propagator, so the second
    // return value ("removed") is false. This is the one init hook that has both
    // the Solver and the InitClauseCreator, so it also links each conditional
    // element to its condition: it creates an auxiliary activity variable a_o in
    // [0, r_o] and two permanent clauses,
    //     cond      -> a_o >= r_o     {-cond, -[a_o <= r_o-1]}
    //     not cond  -> a_o <= 0       { cond,  [a_o <= 0]     }
    // so [a_o <= 0] == NOT cond and lower_bound(a_o) > 0 == cond, and then watches
    // a_o. clingcon watches integer variables, not raw condition literals; with
    // this link a condition that is decided late moves a_o's bound and re-enqueues
    // the constraint. Unconditional elements keep
    // act == INVALID_ACT and need no variable. Runs once, on the master, before
    // the worker states are copied.
    [[nodiscard]] auto translate(Config const &config, Solver &solver, InitClauseCreator &cc, ConstraintVec &added)
        -> std::pair<bool, bool> override {
        static_cast<void>(added);
        constraint_.explanation(config.cumu_explanation);
        auto &elems = constraint_.elements_mut();
        val_t tag = 1;
        for (std::size_t o = 0; o < elems.size(); ++o, ++tag) {
            auto &e = elems[o];
            if (e.condition == TRUE_LIT || e.condition == -TRUE_LIT || e.act != INVALID_ACT) {
                continue; // unconditional (always active) or already wired
            }
            var_t const a = solver.add_variable(0, e.demand); // fresh aux var, domain [0, r_o]
            lit_t const le0 = solver.get_literal(cc, solver.var_state(a), 0);            // [a <= 0]
            lit_t const lem = solver.get_literal(cc, solver.var_state(a), e.demand - 1); // [a <= r_o-1]
            if (!cc.add_clause({-e.condition, -lem})) { // cond -> a >= r_o
                return {false, false};
            }
            if (!cc.add_clause({e.condition, le0})) { // not cond -> a <= 0
                return {false, false};
            }
            e.act = a;
            solver.add_var_watch(a, tag, *this); // re-trigger propagate() on a late condition flip
        }
        return {true, false};
    }

    // ---- watches -------------------------------------------------------------
    void attach(Solver &solver) override {
        val_t tag = 1;
        for (auto const &e : constraint_.elements()) {
            // Watch each start variable. The tag (here just an index) is handed
            // back in update()/undo(); we recompute from scratch, so its value
            // is irrelevant beyond being non-zero.
            solver.add_var_watch(e.start, tag, *this);
            // Mirror detach(). translate() installs this watch the first time
            // (attach() runs before it, so act is still INVALID_ACT then), and
            // attach() restores it on a re-attach after a detach. Without it the
            // condition watch would be lost; removable() is true, so that path
            // is reachable.
            if (e.act != INVALID_ACT) {
                solver.add_var_watch(e.act, tag, *this);
            }
            ++tag;
        }
    }

    void detach(Solver &solver) override {
        val_t tag = 1;
        for (auto const &e : constraint_.elements()) {
            solver.remove_var_watch(e.start, tag, *this);
            if (e.act != INVALID_ACT) {
                solver.remove_var_watch(e.act, tag, *this); // mirror the translate() watch
            }
            ++tag;
        }
    }

    // A watched bound moved: we recompute the profile from current bounds in
    // propagate(), so there is no incremental state to maintain here. Returning
    // true requests (re)propagation.
    [[nodiscard]] auto update(val_t i, val_t diff) -> bool override {
        static_cast<void>(i);
        static_cast<void>(diff);
        return true;
    }

    void undo(val_t i, val_t diff) override {
        static_cast<void>(i);
        static_cast<void>(diff);
    }

    // ---- the propagator ------------------------------------------------------
    [[nodiscard]] auto propagate(Solver &solver, AbstractClauseCreator &cc, bool check_state) -> bool override {
        static_cast<void>(check_state);
        auto const &elems = constraint_.elements();
        auto const cap = constraint_.capacity();
        auto ass = cc.assignment();

        // An element is an active task only when its condition holds. For a
        // conditional element we read the auxiliary activity variable's lower bound
        // (lb(a_o) > 0 == cond; see translate()) rather than the raw condition
        // literal, because a_o is watched. Unconditional elements
        // (act == INVALID_ACT) test their constant condition literal.
        auto active = [&](std::size_t o) { return elem_active(solver, ass, o); };

        // Compulsory-part time table. CP(o) = [ ub(s_o), lb(s_o) + d_o ) with
        // lb = earliest start (underline s_o), ub = latest start (overline s_o):
        // the interval task o must occupy no matter where it finally starts.
        // Build the +/- demand events of every non-empty compulsory part.
        // The event list and the profile are rebuilt on every call. Their buffers
        // are kept in the state between calls to avoid reallocating them; they are
        // moved out here and handed back on exit, so a nested call would simply
        // start from empty buffers.
        BufferLease lease{*this};
        auto &events = lease.events;
        events.clear();
        events.reserve(2 * elems.size());
        for (std::size_t o = 0; o < elems.size(); ++o) {
            if (!active(o)) {
                continue; // inactive element: not a task
            }
            auto &vs = solver.var_state(elems[o].start);
            val_t lo = vs.upper_bound();                      // overline s_o
            val_t hi = vs.lower_bound() + elems[o].duration;  // underline s_o + d_o
            if (lo < hi) {                                    // non-empty compulsory part
                events.push_back(Event{lo, elems[o].demand, false});
                events.push_back(Event{hi, elems[o].demand, true});
            }
        }
        if (events.empty()) {
            return true;
        }

        // Sort by time; at equal times apply ends before starts (CPs are
        // half-open, so a task ending at t no longer counts at t).
        std::sort(events.begin(), events.end(), [](Event const &a, Event const &b) {
            if (a.time != b.time) {
                return a.time < b.time;
            }
            return a.is_end && !b.is_end;
        });

        // One left-to-right sweep; also record the compressed profile
        // prof[i] = (slab_start, usage on [slab_start, next_slab_start)). The
        // profile is constant on each slab, so an overload is caught at its left
        // end t (the O(n) witness gather runs only when one is found).
        auto &prof = lease.prof;
        prof.clear();
        prof.reserve(events.size());
        sum_t usage = 0;
        for (std::size_t i = 0; i < events.size();) {
            val_t const t = events[i].time;
            for (; i < events.size() && events[i].time == t; ++i) {
                usage += events[i].is_end ? -events[i].demand : events[i].demand;
            }
            prof.emplace_back(t, usage);
            if (usage > static_cast<sum_t>(cap)) {
                // Overload on [t, next): witnesses are the tasks whose compulsory
                // part covers t. The false return drives clasp's 1-UIP analysis.
                //
                // Minimal witness set: a subset of covering tasks whose demands
                // already exceed cap is enough. A shorter clause is a more
                // general nogood. The sweep guarantees that the demands of the
                // covering tasks sum to usage > cap, so the greedy gather below
                // always reaches got > cap.
                std::vector<std::size_t> omega;
                sum_t got = 0;
#ifdef CLINGU_FULL_WITNESS
                // Full witness set (ablation build): gather every covering task,
                // not just a cap-exceeding subset.
                for (std::size_t o = 0; o < elems.size(); ++o) {
                    (void)got;
#else
                for (std::size_t o = 0; o < elems.size() && got <= static_cast<sum_t>(cap); ++o) {
#endif
                    if (!active(o)) {
                        continue;
                    }
                    auto &vs = solver.var_state(elems[o].start);
                    if (vs.upper_bound() <= t && t < vs.lower_bound() + elems[o].duration) {
                        omega.push_back(o);
                        got += elems[o].demand;
                    }
                }
                // The overloaded step is [t, next event). An overload implies a
                // later event, so i is in range here.
                val_t const step_end = i < events.size() ? events[i].time : t + 1;
                if (!add_conflict(solver, cc, omega, t, expl_end(t, step_end))) {
                    return false;
                }
            }
        }

        // ---- Bound pushing (time-table filtering) ---------------------------
        // The profile is now <= cap everywhere. A task o cannot run at any
        // instant t outside its own compulsory part where prof(t) + r_o > cap.
        // Push its earliest start past the furthest such blocked instant in its
        // earliest window [lb, min(lb+d, ub)); else push its latest start before
        // the nearest one in its latest window [max(ub, lb+d), ub+d). Each push
        // carries the pointwise reason and feeds the new bound back into the
        // &sum layer. A tightened bound re-enqueues this constraint; we emit at
        // most one push per task per call and reach the fixpoint over re-calls.
        auto const caps = static_cast<sum_t>(cap);
        // A task can only be blocked where the profile plus its demand exceeds the
        // capacity. With the highest point of the profile at hand, a task that
        // fits even there is skipped without looking at the profile.
        sum_t max_usage = 0;
        for (auto const &step : prof) {
            max_usage = std::max(max_usage, step.second);
        }
        // Index of the profile step that contains instant x (0 if x lies before
        // the first step), found by binary search. The scans below start there
        // and stop at the end of the task's window instead of walking the whole
        // profile.
        auto step_at = [&prof](val_t x) -> std::size_t {
            auto it = std::upper_bound(prof.begin(), prof.end(), x,
                                       [](val_t v, std::pair<val_t, sum_t> const &step) { return v < step.first; });
            return it == prof.begin() ? 0 : static_cast<std::size_t>(it - prof.begin()) - 1;
        };
        for (std::size_t o = 0; o < elems.size(); ++o) {
            if (!active(o)) {
                continue; // only push active tasks
            }
            if (max_usage + elems[o].demand <= caps) {
                continue; // not blocked anywhere
            }
            auto &vo = solver.var_state(elems[o].start);
            val_t const lb = vo.lower_bound();
            val_t const ub = vo.upper_bound();
            if (lb >= ub) {
                continue; // fixed start; any real overload is caught by the sweep
            }
            val_t const d = elems[o].duration;
            val_t const r = elems[o].demand;

            // earliest-start push: furthest blocked instant in [lb, min(lb+d, ub))
            val_t const lo_hi = std::min(lb + d, ub);
            val_t blk = 0;
            val_t step_lo = 0; // the profile step [step_lo, step_hi) that contains blk
            val_t step_hi = 0;
            bool found = false;
            for (std::size_t i = step_at(lb); i + 1 < prof.size() && prof[i].first < lo_hi; ++i) {
                if (prof[i].second + r <= caps) {
                    continue;
                }
                val_t const a = std::max(prof[i].first, lb);
                val_t const b = std::min(prof[i + 1].first, lo_hi);
                if (a < b && (!found || b - 1 > blk)) {
                    blk = b - 1;
                    step_lo = prof[i].first;
                    step_hi = prof[i + 1].first;
                    found = true;
                }
            }
            if (found && blk + 1 > lb) {
                bool const ok = bigstep_push() ? push_bound(solver, cc, o, step_lo, step_hi, /*lower=*/true)
                                               : push_bound(solver, cc, o, blk, blk + 1, /*lower=*/true);
                if (!ok) {
                    return false;
                }
                continue; // one push per task per call; profile is rebuilt next call
            }

            // latest-start push: nearest blocked instant in [max(ub, lb+d), ub+d)
            val_t const hi_lo = std::max(ub, lb + d);
            found = false;
            for (std::size_t i = step_at(hi_lo); i + 1 < prof.size() && prof[i].first < ub + d; ++i) {
                if (prof[i].second + r <= caps) {
                    continue;
                }
                val_t const a = std::max(prof[i].first, hi_lo);
                val_t const b = std::min(prof[i + 1].first, ub + d);
                if (a < b && (!found || a < blk)) {
                    blk = a;
                    step_lo = prof[i].first;
                    step_hi = prof[i + 1].first;
                    found = true;
                }
            }
            if (found && blk - d < ub) {
                bool const ok = bigstep_push() ? push_bound(solver, cc, o, step_lo, step_hi, /*lower=*/false)
                                               : push_bound(solver, cc, o, blk, blk + 1, /*lower=*/false);
                if (!ok) {
                    return false;
                }
            }
        }
        // ---- Presence propagation (rule F4) ---------------------------------
        // An undecided conditional element whose compulsory part [ub, lb+d) meets
        // its blocked region (prof + r_o > cap; prof excludes o since o is not
        // active) cannot be activated without an overload: infer NOT c_o. The
        // clause has the deactivation literal [a_o <= 0] as consequent
        // (== NOT c_o via the translate() clauses).
#ifdef CLINGU_F4
        // Off by default: on the eVTOL benchmark F4 slowed search.
        // Build with CLINGU_CXX_FLAGS="-DCLINGU_F4" to enable it.
        for (std::size_t o = 0; o < elems.size(); ++o) {
            auto const &e = elems[o];
            if (e.act == INVALID_ACT || ass.is_true(e.condition) || ass.is_false(e.condition)) {
                continue; // unconditional, or decided
            }
            if (e.demand <= 0) {
                continue;
            }
            auto &vo = solver.var_state(e.start);
            val_t const cp_lo = vo.upper_bound();
            val_t const cp_hi = vo.lower_bound() + e.duration;
            if (cp_lo >= cp_hi) {
                continue; // empty compulsory part
            }
            bool found = false;
            val_t tau = 0;
            val_t tau_end = 0;
            for (std::size_t i = 0; i + 1 < prof.size(); ++i) {
                if (prof[i].second + e.demand <= caps) {
                    continue;
                }
                val_t const a = std::max(prof[i].first, cp_lo);
                val_t const b = std::min(prof[i + 1].first, cp_hi);
                if (a < b) {
                    tau = a;     // [a, b): the first blocked step, cut to CP(o)
                    tau_end = b;
                    found = true;
                    break;
                }
            }
            if (found && !push_presence(solver, cc, o, tau, expl_end(tau, tau_end))) {
                return false;
            }
        }
#endif
        return true;
    }

    // Full check on a total assignment, as a backstop. The auxiliary activity
    // variables make the active set readable from bounds alone: an element is
    // active iff it is unconditional with a true condition, or
    // lower_bound(a_o) > 0. Inactive elements are skipped, since their start
    // variables may hold arbitrary values. On a fully propagated model this never
    // fires; if an overload escaped propagation it throws instead of letting the
    // model through.
    void check_full(Solver &solver) override {
        auto const &elems = constraint_.elements();
        auto const cap = static_cast<sum_t>(constraint_.capacity());
        struct Ev {
            val_t time;
            val_t demand;
            bool is_end;
        };
        std::vector<Ev> events;
        events.reserve(2 * elems.size());
        for (std::size_t o = 0; o < elems.size(); ++o) {
            auto const &e = elems[o];
            // Same activity test as elem_active(), but from bounds alone: for a
            // constant condition (act == INVALID_ACT) the element is active iff the
            // condition is TRUE_LIT.
            bool const act = (e.act == INVALID_ACT) ? (e.condition == TRUE_LIT)
                                                    : (solver.var_state(e.act).lower_bound() > 0);
            if (!act) {
                continue; // inactive: its start var may hold an arbitrary split value
            }
            val_t const s = solver.var_state(e.start).lower_bound(); // assigned => lb == value
            events.push_back(Ev{s, e.demand, false});
            events.push_back(Ev{s + e.duration, e.demand, true});
        }
        if (events.empty()) {
            return;
        }
        std::sort(events.begin(), events.end(), [](Ev const &a, Ev const &b) {
            if (a.time != b.time) {
                return a.time < b.time;
            }
            return a.is_end && !b.is_end; // ends before starts at equal time (half-open intervals)
        });
        sum_t usage = 0;
        for (std::size_t i = 0; i < events.size();) {
            val_t const t = events[i].time;
            for (; i < events.size() && events[i].time == t; ++i) {
                usage += events[i].is_end ? -events[i].demand : events[i].demand;
            }
            if (usage > cap) { // strict: usage equal to the capacity is allowed
                throw std::logic_error("invalid cumulative solution");
            }
        }
    }

    // ---- todo-set bookkeeping ------------------------------------------------
    auto mark_todo(bool todo) -> bool override {
        auto ret = todo_;
        todo_ = todo;
        return ret;
    }
    [[nodiscard]] auto marked_todo() const -> bool override { return todo_; }

    [[nodiscard]] auto removable() -> bool override { return true; }

  protected:
    [[nodiscard]] auto inactive_level() const -> level_t override { return inactive_level_; }
    void inactive_level(level_t level) override { inactive_level_ = level; }

  private:
    [[nodiscard]] auto bigstep() const -> bool { return constraint_.explanation() == CumuExplanation::BigStep; }
    //! Whether a bound push refers to a whole profile step (bigstep and mixed).
    [[nodiscard]] auto bigstep_push() const -> bool {
        return bigstep() || constraint_.explanation() == CumuExplanation::Mixed;
    }
    [[nodiscard]] auto naive() const -> bool { return constraint_.explanation() == CumuExplanation::Naive; }

    //! End of the interval an explanation refers to: the whole profile step
    //! [lo, step_end) for big-step explanations, the single instant lo otherwise.
    [[nodiscard]] auto expl_end(val_t lo, val_t step_end) const -> val_t { return bigstep() ? step_end : lo + 1; }

    //! Activity test shared by propagate()/push_bound()/check_full(): unconditional
    //! elements (act == INVALID_ACT) are always active (TRUE_LIT); conditional ones
    //! are active iff their aux var's lower bound is positive (== condition true).
    [[nodiscard]] auto elem_active(Solver &solver, Clingo::Assignment const &ass, std::size_t o) -> bool {
        auto const &e = constraint_.elements()[o];
        if (e.act == INVALID_ACT) {
            return ass.is_true(e.condition);
        }
        return solver.var_state(e.act).lower_bound() > 0;
    }

    //! The "not active" literal for emitted nogoods: [a_o <= 0] for a conditional
    //! element (== NOT cond via the translate() clauses), or -condition (a false
    //! literal, dropped by add_clause) if unconditional.
    [[nodiscard]] auto deact_lit(Solver &solver, AbstractClauseCreator &cc, std::size_t o) -> lit_t {
        auto const &e = constraint_.elements()[o];
        if (e.act == INVALID_ACT) {
            return -e.condition;
        }
        return solver.get_literal(cc, solver.var_state(e.act), 0);
    }

    //! The order literal [s <= v], made true in the current assignment. Requires
    //! ub(s) <= v, so the literal follows from the bound literal [s <= ub(s)].
    //! clingcon creates order literals on demand and unassigned; a literal at a
    //! value other than a current bound therefore has to be linked to the bound
    //! literal before a clause can rely on its value. This is the order clause
    //! clingcon itself adds between existing literals. Sets ok to false on a
    //! conflict.
    [[nodiscard]] auto le_true(Solver &solver, AbstractClauseCreator &cc, VarState &vs, val_t v, bool &ok) -> lit_t {
        assert(vs.upper_bound() <= v);
        lit_t const lit = solver.get_literal(cc, vs, v);
        if (ok && !cc.assignment().is_true(lit)) {
            ok = cc.add_clause({-solver.get_literal(cc, vs, vs.upper_bound()), lit});
        }
        return lit;
    }

    //! The order literal [s <= v], made false in the current assignment. Requires
    //! v < lb(s), so its negation follows from NOT [s <= lb(s) - 1]. See le_true.
    [[nodiscard]] auto le_false(Solver &solver, AbstractClauseCreator &cc, VarState &vs, val_t v, bool &ok) -> lit_t {
        assert(v < vs.lower_bound());
        lit_t const lit = solver.get_literal(cc, vs, v);
        if (ok && !cc.assignment().is_false(lit)) {
            ok = cc.add_clause({solver.get_literal(cc, vs, vs.lower_bound() - 1), -lit});
        }
        return lit;
    }

    //! Appends the two order literals that are false exactly when task k starts
    //! in the range the explanation form allows for covering [lo, hi):
    //!   pointwise / big-step : s_k <= lo and s_k >= hi - d_k
    //!                          (pointwise passes hi == lo + 1, the band [lo-d_k+1, lo]);
    //!   naive                : s_k within its current bounds.
    //! The caller guarantees that the compulsory part of k covers [lo, hi), so the
    //! range holds under the current bounds. Both literals are false in the
    //! assignment on return (see le_true). Returns false on a conflict.
    [[nodiscard]] auto cover_lits(Solver &solver, AbstractClauseCreator &cc, std::size_t k, val_t lo, val_t hi,
                                  std::vector<lit_t> &clause) -> bool {
        auto &vk = solver.var_state(constraint_.elements()[k].start);
        bool ok = true;
        if (naive()) {
            val_t const lb = vk.lower_bound();
            val_t const ub = vk.upper_bound();
            clause.push_back(-solver.get_literal(cc, vk, ub));    // NOT [s_k <= ub]
            clause.push_back(solver.get_literal(cc, vk, lb - 1)); //     [s_k <= lb - 1]
        } else {
            val_t const dk = constraint_.elements()[k].duration;
            clause.push_back(-le_true(solver, cc, vk, lo, ok));          // NOT [s_k <= lo]
            clause.push_back(le_false(solver, cc, vk, hi - dk - 1, ok)); //     [s_k <= hi - d_k - 1]
        }
        return ok;
    }

    //! Explanation of an overload on [lo, hi) witnessed by the task indices in
    //! `omega`. Each o in omega is active and its compulsory part covers [lo, hi).
    //! The conflict clause is the negation of "every witness is active and starts
    //! in its range" (see cover_lits). Returns false on conflict, as cc.add_clause
    //! does.
    [[nodiscard]] auto add_conflict(Solver &solver, AbstractClauseCreator &cc, std::vector<std::size_t> const &omega,
                                    val_t lo, val_t hi) -> bool {
        std::vector<lit_t> clause;
        clause.reserve(3 * omega.size());
        for (auto o : omega) {
            clause.push_back(deact_lit(solver, cc, o)); // NOT active_o ([a_o<=0], or -TRUE_LIT)
            if (!cover_lits(solver, cc, o, lo, hi, clause)) {
                return false;
            }
        }
        ++solver.statistics().cumu_conflict_clauses;
        return cc.add_clause(clause);
    }

    //! Bound-push explanation: task o cannot overlap [lo, hi), because the
    //! blocking tasks' compulsory parts cover it and together with r_o exceed cap.
    //! Pointwise and naive explanations pass a single instant (hi == lo + 1);
    //! big-step and mixed pass a whole step of the profile.
    //!   lower : reason NOT [s_o <= lo - d_o], consequent NOT [s_o <= hi - 1]
    //!   upper : reason     [s_o <= hi - 1],   consequent     [s_o <= lo - d_o]
    //! (naive uses o's current bound as the reason instead). All reason literals
    //! are currently true, so the clause unit-propagates the consequent (pushing
    //! the bound) or, if it conflicts, returns false.
    [[nodiscard]] auto push_bound(Solver &solver, AbstractClauseCreator &cc, std::size_t o, val_t lo, val_t hi,
                                  bool lower) -> bool {
        auto const &elems = constraint_.elements();
        [[maybe_unused]] auto const cap = static_cast<sum_t>(constraint_.capacity());
        auto ass = cc.assignment();
        auto &vo = solver.var_state(elems[o].start);
        val_t const d = elems[o].duration;

        std::vector<lit_t> clause;
        bool ok = true;
        // o is an active task (false-lit if unconditional, dropped by add_clause).
        clause.push_back(deact_lit(solver, cc, o));
        // o's own literal: o overlaps [lo, hi) whenever it starts in (lo - d_o, hi - 1].
        // The reason is the half of that range the push does not conclude.
        // The naive form uses o's current bound instead; the clause is still valid
        // but more specific. (CLINGU_NAIVE_OWN_LITERAL does the same for this
        // literal only, keeping the other tasks pointwise: the v1 behaviour.)
#ifdef CLINGU_NAIVE_OWN_LITERAL
        bool const own_bound = true;
#else
        bool const own_bound = naive();
#endif
        if (own_bound) {
            if (lower) {
                clause.push_back(solver.get_literal(cc, vo, vo.lower_bound() - 1));
            } else {
                clause.push_back(-solver.get_literal(cc, vo, vo.upper_bound()));
            }
        } else if (lower) {
            clause.push_back(le_false(solver, cc, vo, lo - d, ok)); //     [s_o <= lo - d_o]
        } else {
            clause.push_back(-le_true(solver, cc, vo, hi - 1, ok)); // NOT [s_o <= hi - 1]
        }
        if (!ok) {
            return false;
        }
        // enough active blocking tasks whose compulsory part covers [lo, hi). The
        // profile is constant on a step, so covering lo means covering all of it.
        sum_t got = 0;
        for (std::size_t k = 0; k < elems.size(); ++k) {
            if (k == o || !elem_active(solver, ass, k)) {
                continue;
            }
            auto &vk = solver.var_state(elems[k].start);
            val_t const dk = elems[k].duration;
            if (vk.upper_bound() <= lo && lo < vk.lower_bound() + dk) {
                clause.push_back(deact_lit(solver, cc, k)); // NOT active_k
                if (!cover_lits(solver, cc, k, lo, hi, clause)) {
                    return false;
                }
                got += elems[k].demand;
#ifndef CLINGU_FULL_WITNESS
                // Minimal witness (default): stop once the blockers together with
                // o exceed cap. Define CLINGU_FULL_WITNESS to gather all of them.
                if (got + elems[o].demand > cap) {
                    break;
                }
#endif
            }
        }
        // consequent: the new, tighter bound on s_o.
        if (lower) {
            clause.push_back(-solver.get_literal(cc, vo, hi - 1));  // [s_o >= hi]
        } else {
            clause.push_back(solver.get_literal(cc, vo, lo - d));   // [s_o <= lo - d_o]
        }
        ++solver.statistics().cumu_push_clauses;
        return cc.add_clause(clause);
    }

    //! Rule F4 explanation: o, undecided, covers [lo, hi) under its current
    //! bounds, and the active blockers covering it already fill the resource to
    //! more than cap - r_o, so o cannot be active:
    //!   o starts in its range AND the blockers start in theirs  ->  NOT c_o,
    //! emitted with [a_o <= 0] (== NOT c_o) as the consequent. All antecedent
    //! literals are true, so the clause is unit and decides the condition.
    [[nodiscard]] auto push_presence(Solver &solver, AbstractClauseCreator &cc, std::size_t o, val_t lo, val_t hi)
        -> bool {
        auto const &elems = constraint_.elements();
        [[maybe_unused]] auto const cap = static_cast<sum_t>(constraint_.capacity());
        auto ass = cc.assignment();

        std::vector<lit_t> clause;
        clause.push_back(deact_lit(solver, cc, o)); // consequent: [a_o <= 0]
        if (!cover_lits(solver, cc, o, lo, hi, clause)) {
            return false;
        }
        sum_t got = 0;
        for (std::size_t k = 0; k < elems.size(); ++k) {
            if (k == o || !elem_active(solver, ass, k)) {
                continue;
            }
            auto &vk = solver.var_state(elems[k].start);
            val_t const dk = elems[k].duration;
            if (vk.upper_bound() <= lo && lo < vk.lower_bound() + dk) {
                clause.push_back(deact_lit(solver, cc, k));
                if (!cover_lits(solver, cc, k, lo, hi, clause)) {
                    return false;
                }
                got += elems[k].demand;
#ifndef CLINGU_FULL_WITNESS
                if (got + elems[o].demand > cap) {
                    break; // minimal witness
                }
#endif
            }
        }
        ++solver.statistics().cumu_presence_clauses;
        return cc.add_clause(clause);
    }

    //! A +/- demand event at the start or end of a compulsory part.
    struct Event {
        val_t time;
        val_t demand; // r_o
        bool is_end;  // false at a CP start (+r_o), true at a CP end (-r_o)
    };

    //! Takes the scratch buffers out of the state for the duration of one
    //! propagate() call and puts them back afterwards.
    struct BufferLease {
        explicit BufferLease(CumulativeConstraintState &state)
            : owner{state}, events{std::move(state.events_)}, prof{std::move(state.prof_)} {}
        BufferLease(BufferLease const &) = delete;
        auto operator=(BufferLease const &) -> BufferLease & = delete;
        ~BufferLease() {
            owner.events_ = std::move(events);
            owner.prof_ = std::move(prof);
        }
        CumulativeConstraintState &owner;
        std::vector<Event> events;
        std::vector<std::pair<val_t, sum_t>> prof;
    };

    CumulativeConstraint &constraint_;
    bool todo_ = false;
    level_t inactive_level_ = 0;
    std::vector<Event> events_;                  //!< scratch: event list of the last call
    std::vector<std::pair<val_t, sum_t>> prof_;  //!< scratch: profile of the last call
};

} // namespace

auto CumulativeConstraint::create(lit_t lit, CumulativeElementVec elems, val_t capacity)
    -> std::unique_ptr<CumulativeConstraint> {
    return std::unique_ptr<CumulativeConstraint>(new CumulativeConstraint(lit, std::move(elems), capacity));
}

auto CumulativeConstraint::create_state() -> UniqueConstraintState {
    return std::make_unique<CumulativeConstraintState>(*this);
}

} // namespace Clingcon
