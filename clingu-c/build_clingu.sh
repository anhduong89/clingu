#!/usr/bin/env bash
# Build clingu = clingcon + the &cumu cumulative propagator.
#
# Verified end-to-end with g++ 11, clingo 5.8 (pip), clingcon @ HEAD (5.2.1) on
# CPython 3.13. Builds the importable `clingcon` Python module and runs a smoke
# test that must print UNSATISFIABLE.
#
# The produced extension (_clingcon.cpython-<ver>-*.so) is ABI-locked to ONE
# Python. The whole build therefore keys off a single interpreter ($PY): pip
# installs into it, and cmake is pinned to it. Run solver.py with that SAME
# interpreter afterwards.
#
# Usage:
#   bash build_clingu.sh                      # uses `python3` on PATH
#   PY=~/miniconda3/envs/clingu/bin/python3 bash build_clingu.sh   # pick one
#   CLINGCU=/path/to/clingu WORK=/path/to/builddir bash build_clingu.sh
set -euo pipefail

CLINGCU="${CLINGCU:-$(cd "$(dirname "$0")" && pwd)}"   # holds cumulative.{hh,cc} + the patch
WORK="${WORK:-$HOME/clingu-build}"

# Resolve the target interpreter to an absolute path; everything below uses it.
PY="${PY:-python3}"
PYEXE="$(command -v "$PY")" || { echo "python not found: $PY" >&2; exit 1; }
echo ">> target python: $PYEXE ($("$PYEXE" --version 2>&1))"
# pip-installed cmake/ninja land next to this python (or in ~/.local/bin with
# --user); put both ahead of PATH so the matching tools are picked up.
export PATH="$(dirname "$PYEXE"):$HOME/.local/bin:$PATH"

echo ">> [1/6] dependencies (clingo headers, cmake, ninja, scikit-build)"
# Install into the interpreter's own environment when its site-packages is
# writable (conda env / venv); fall back to --user only for a read-only system
# python. (--user is rejected inside a venv, so this avoids that failure too.)
USERFLAG="$("$PYEXE" -c "import sysconfig,os;print('' if os.access(sysconfig.get_paths()['purelib'],os.W_OK) else '--user')")"
"$PYEXE" -m pip install $USERFLAG -q clingo==5.8.0 cmake ninja scikit-build

echo ">> [2/6] clone clingcon into $WORK"
# Pin the clingcon commit (82fc140 = clingcon 5.2.1), so
# that clingcon-wiring.patch applies. A full clone (no --depth 1) is required
# for the checkout to resolve. Override with CLINGCON_COMMIT=<hash>.
CLINGCON_COMMIT="${CLINGCON_COMMIT:-82fc1406d65d0ab98e70b51796f7c9e520612d6e}"
# $WORK is wiped below, so refuse the values that would take something else with
# it. WORK=$HOME (or /, or an empty WORK) must not reach the rm.
case "${WORK:-}" in
  ""|"/"|"$HOME"|"$HOME/") echo "refusing to wipe WORK='$WORK'" >&2; exit 1 ;;
esac
rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK"
git clone https://github.com/potassco/clingcon
cd clingcon
git checkout "$CLINGCON_COMMIT"

echo ">> [3/6] add the cumulative source + apply the wiring patch"
# CLINGCU is the directory that holds this script, cumulative.{hh,cc} and the
# patch (all flat in clingu-c/), so reference them directly -- no nested
# clingu-c/ prefix.
cp "$CLINGCU/clingcon/cumulative.hh" libclingcon/clingcon/
cp "$CLINGCU/src/cumulative.cc"      libclingcon/src/
git apply "$CLINGCU/clingcon-wiring.patch"

echo ">> [4/6] configure (pip mode) + build"
CDIR=$("$PYEXE" -c "import clingo,os;print(os.path.dirname(clingo.__file__))")
SKB=$("$PYEXE" -c "import skbuild,os;print(os.path.join(os.path.dirname(skbuild.__file__),'resources','cmake'))")
# Pin cmake to $PYEXE. Without this, cmake's FindPython/FindPythonLibs can pick a
# DIFFERENT libpython on the box (e.g. conda base 3.12 instead of an env's 3.13),
# producing a .so tagged for the wrong ABI that the target python cannot import.
# Pass both the modern (Python_*) and legacy (PYTHON_*) variable names because the
# clingcon CMake has a fallback path that uses find_package(PythonLibs). Derive
# libpython version-agnostically from LDVERSION (e.g. "3.13").
PYINC=$("$PYEXE" -c "import sysconfig;print(sysconfig.get_path('include'))")
PYLIB=$("$PYEXE" -c "import sysconfig,os;d=sysconfig.get_config_var('LIBDIR') or '';v=sysconfig.get_config_var('LDVERSION') or sysconfig.get_python_version();c1=os.path.join(d,'libpython%s.so'%v);c2=os.path.join(d,sysconfig.get_config_var('LDLIBRARY') or '');print(c1 if os.path.exists(c1) else (c2 if os.path.exists(c2) else c1))")
# Extra C++ flags for the ablation builds, e.g. CLINGU_CXX_FLAGS="-DCLINGU_FULL_WITNESS"
# (full witness set), "-DCLINGU_F4" (presence propagation on),
# "-DCLINGU_NAIVE_OWN_LITERAL" (v1 push literal). The
# explanation form is a run-time option (--cumu-explanation), not a flag.
CLINGU_CXX_FLAGS="${CLINGU_CXX_FLAGS:-}"
cmake -G Ninja -Bbuild \
  -DPYCLINGCON_ENABLE=pip -DPYCLINGCON_PIP_PATH="$CDIR" \
  -DPython_EXECUTABLE="$PYEXE" -DPython3_EXECUTABLE="$PYEXE" -DPYTHON_EXECUTABLE="$PYEXE" \
  -DPython_INCLUDE_DIR="$PYINC" -DPython_LIBRARY="$PYLIB" \
  -DPYTHON_INCLUDE_DIR="$PYINC" -DPYTHON_LIBRARY="$PYLIB" \
  -DCMAKE_BUILD_TYPE=Release -DCLINGCON_BUILD_TESTS=OFF \
  -DCMAKE_CXX_FLAGS="$CLINGU_CXX_FLAGS" \
  -DCMAKE_MODULE_PATH="$SKB"
cmake --build build -j"${BUILD_JOBS:-$(nproc)}"

echo ">> [5/6] install the built extension into the python package"
cp build/bin/python/_clingcon*.so libpyclingcon/clingcon/

echo ">> [6/6] smoke test (must say UNSATISFIABLE)"
SMOKE=$(mktemp -t clingu_smoke.XXXXXX)
trap 'rm -f "$SMOKE"' EXIT
cat > "$SMOKE" <<'EOF'
#const w = 10.
op(1..3). cap(2).
&dom{0..30} = s(O) :- op(O).
&sum{ s(1) } = 0.  &sum{ s(2) } = 5.  &sum{ s(3) } = 8.
&cumu{ s(O), w, 1 : op(O) } <= C :- cap(C).
EOF
# The smoke instance is over capacity by construction, so anything other than
# UNSATISFIABLE means the propagator is not wired in (or is wrong). Fail loudly:
# a silent pass here is worse than no smoke test at all.
SMOKE_OUT=$(PYTHONPATH="$PWD/libpyclingcon" "$PYEXE" -m clingcon "$SMOKE" 2>&1) || true
printf '%s\n' "$SMOKE_OUT"
if ! printf '%s' "$SMOKE_OUT" | grep -q UNSATISFIABLE; then
    echo "" >&2
    echo "SMOKE TEST FAILED: expected UNSATISFIABLE (see output above)." >&2
    exit 1
fi

cat <<EOF

================================================================
clingu is built for: $PYEXE

Run your own models with THAT python:

  PYTHONPATH=$PWD/libpyclingcon $PYEXE -m clingcon YOUR.lp INSTANCE.lp

(Expected smoke-test result above: UNSATISFIABLE — three width-10
operations overlap at capacity 2.)
================================================================
EOF
