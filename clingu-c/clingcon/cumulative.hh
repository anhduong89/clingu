// libclingcon/clingcon/cumulative.hh
//
// Copyright (c) 2026 New Mexico State University
// SPDX-License-Identifier: MIT
//
// Original work. Declares the constraint against clingcon's public C++
// interface so that it compiles inside clingcon's libclingcon/ tree; no
// clingcon source is copied here. See ../../NOTICE.
//
// Cumulative global constraint for clingu (= clingcon + a cumulative
// propagator). Declares the constraint object; the thread-specific propagator
// state and the time-table reasoning live in src/cumulative.cc.
//
// Designed to plug into clingcon's existing Solver/Propagator machinery via the
// same public constraint interface its built-in constraints use: it reuses
// clingcon's integer variables (VarState) and their lazy order literals
// [s_o <= k], so every explanation it emits is already a Boolean clause over
// solver literals that clasp's 1-UIP can resolve against &sum / route nogoods.

#pragma once

#include <clingcon/base.hh>   // lit_t, var_t, val_t, ...
#include <clingcon/solver.hh> // AbstractConstraint, UniqueConstraintState

#include <limits>
#include <memory>
#include <vector>

namespace Clingcon {

//! Sentinel for CumulativeElement::act: "unconditional element" (no aux var).
inline constexpr var_t INVALID_ACT = std::numeric_limits<var_t>::max();

//! One task of a cumulative constraint: a start variable with a constant
//! duration and a constant resource demand.
//!
//! For the eVTOL vertiport core this is the unit-demand, uniform-window
//! specialization: `duration == W` and `demand == 1` for every task, and the
//! capacity is `cap(v)`.
struct CumulativeElement {
    var_t start;     //!< index of the start variable s_o (a clingcon integer var)
    val_t duration;  //!< d_o   (== W in the uniform-window case)
    val_t demand;    //!< r_o   (== 1 in the unit-demand case)
    lit_t condition; //!< solver literal gating this task (TRUE_LIT if unconditional).
                     //!< A theory element `tuple : cond` is only an active task when
                     //!< `cond` holds; without this the grounder's per-`W`/per-edge
                     //!< copies of one flight would each be counted (massive overload).
    var_t act = INVALID_ACT; //!< aux activity var (INVALID_ACT if unconditional). Created at
                             //!< translate(): [act<=0] == NOT condition, lower_bound(act)>0 == condition.
                             //!< Watched so a LATE condition flip re-triggers propagation -- the fix
                             //!< for the missing condition-watch soundness bug.
};
using CumulativeElementVec = std::vector<CumulativeElement>;

//! A cumulative constraint enforcing, for every instant tau,
//!
//!     sum_{o : s_o <= tau < s_o + d_o}  r_o   <=   capacity.
//!
//! Conforms to clingcon's constraint interface, so it slots into the same
//! factory / Solver / Propagator path (see src/cumulative.cc and the README
//! wiring).
class CumulativeConstraint final : public AbstractConstraint {
  public:
    //! Allocate a constraint. `lit` is the solver literal that activates it
    //! (one constraint per vertiport in the eVTOL model).
    [[nodiscard]] static auto create(lit_t lit, CumulativeElementVec elems, val_t capacity)
        -> std::unique_ptr<CumulativeConstraint>;

    CumulativeConstraint() = delete;
    CumulativeConstraint(CumulativeConstraint const &) = delete;
    CumulativeConstraint(CumulativeConstraint &&) = delete;
    auto operator=(CumulativeConstraint const &) -> CumulativeConstraint & = delete;
    auto operator=(CumulativeConstraint &&) -> CumulativeConstraint & = delete;
    ~CumulativeConstraint() override = default;

    //! Create the thread-specific propagator state (clasp is parallel).
    [[nodiscard]] auto create_state() -> UniqueConstraintState override;

    //! The literal that reifies / activates this constraint.
    [[nodiscard]] auto literal() const -> lit_t override { return lit_; }

    [[nodiscard]] auto capacity() const -> val_t { return capacity_; }
    [[nodiscard]] auto elements() const -> CumulativeElementVec const & { return elements_; }
    //! Mutable element access -- used once at translate() to record each element's aux var.
    [[nodiscard]] auto elements_mut() -> CumulativeElementVec & { return elements_; }

    //! The explanation form of the clauses this constraint emits (option
    //! --cumu-explanation). Set once at translate(), before the per-thread states
    //! are copied, and only read afterwards.
    [[nodiscard]] auto explanation() const -> CumuExplanation { return explanation_; }
    void explanation(CumuExplanation form) { explanation_ = form; }

  private:
    CumulativeConstraint(lit_t lit, CumulativeElementVec elems, val_t capacity)
        : lit_{lit}, capacity_{capacity}, elements_{std::move(elems)} {}

    lit_t lit_;
    val_t capacity_;
    CumulativeElementVec elements_;
    CumuExplanation explanation_{DEFAULT_CUMU_EXPLANATION};
};

} // namespace Clingcon
