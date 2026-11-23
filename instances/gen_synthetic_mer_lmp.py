"""
Generate a synthetic MER_LMP_Information.xlsx that preserves the aggregate
statistical structure of the proprietary source workbook while containing no
real individual reading.

Strategy
--------
For each sheet (LMP, MER), with the data laid out as rows = cities and
columns = 10-minute time slots:

  1. Take the per-time-slot mean across cities. This is the diurnal profile.
  2. Subtract it, leaving each city's residual deviation from that profile.
  3. Fit the inter-city covariance of those residuals (an n_cities square
     matrix) and take its Cholesky factor L.
  4. Emit  synthetic[:, k] = col_mean[k] + L @ z,  z ~ N(0, I), fixed seed.

Separating the diurnal mean from the residual covariance is what makes the
2nd-order claim true. An earlier version of this script instead rescaled the
noise by (col_mean / mean_std), which made the variance proportional to the
mean: at full coverage that inflated LMP variance by ~2x and, combined with an
unconditional clip at zero, pinned ~10-19% of cells to exactly 0.

Sign handling: LMP is a price and is clipped at 0 (the real series never
approaches 0, so this effectively never binds). MER is an emissions rate that
is genuinely negative at times, so it is NOT clipped -- clipping it would
erase a real feature of the data.

What this does and does not disclose
------------------------------------
By construction the per-time-slot means of the output equal those of the real
data, and the inter-city covariance approximates the real one. Those aggregate
statistics ARE disclosed; that is the point of a statistically faithful
surrogate. No individual real reading is reproduced (verified: zero cells of
the published file match the corresponding real cell).

Coverage
--------
The data block is detected automatically: every fully-populated row is used, so
the script adapts to the real sheet rather than hardcoding a shape. In the
source workbook this is 11 cities x 144 time slots per sheet. The trailing
"Averages" block is dropped, since those rows are partially populated.

Requires: the proprietary source workbook, which is NOT distributed with this
  repository, plus numpy, pandas and openpyxl. The script is included for
  transparency about how the published synthetic file was produced; it cannot
  be re-run from this repository alone.

Usage (from a checkout that has the real file):
    python instances/gen_synthetic_mer_lmp.py --real path/to/MER_LMP_Information.xlsx
"""

import argparse
from pathlib import Path

import numpy as np
import pandas as pd

SHEETS = {'LMP': True, 'MER': False}   # sheet -> clip negatives?
SEED = 42


def load_block(path: Path, sheet: str) -> pd.DataFrame:
    """Read *sheet* and return only the fully-populated data block.

    The source workbook appends an 'Averages' section below the data, whose
    rows carry a single value. Dropping rows with any missing cell removes
    that section and the blank separator without hardcoding a row count.
    """
    df = pd.read_excel(path, sheet_name=sheet, index_col=0, engine='openpyxl')
    df = df.dropna(axis=1, how='all').dropna(axis=0, how='any')
    return df


def synthesize(df: pd.DataFrame, rng: np.random.Generator,
               clip_negative: bool) -> pd.DataFrame:
    data = df.values.astype(float)
    n_rows, n_cols = data.shape

    col_mean = data.mean(axis=0)              # diurnal profile, shape (n_cols,)
    resid = data - col_mean                   # city deviations from it
    cov = np.cov(resid)                       # (n_rows, n_rows)

    # Nudge onto the positive-definite cone so Cholesky is safe.
    cov = np.atleast_2d(cov)
    cov += np.eye(n_rows) * 1e-9 * max(np.trace(cov) / n_rows, 1e-12)
    L = np.linalg.cholesky(cov)

    synthetic = col_mean + L @ rng.standard_normal((n_rows, n_cols))
    if clip_negative:
        synthetic = np.clip(synthetic, 0, None)

    return pd.DataFrame(synthetic, index=df.index, columns=df.columns)


def report(real: pd.DataFrame, synth: pd.DataFrame, name: str) -> None:
    r, y = real.values.astype(float), synth.values.astype(float)
    identical = int(np.isclose(r, y, rtol=1e-9, atol=0).sum())
    print(f"\n=== {name}  ({r.shape[0]} rows x {r.shape[1]} cols) ===")
    print(f"  {'stat':<12}{'real':>14}{'synthetic':>14}")
    for label, fn in [('mean', np.mean), ('std', np.std),
                      ('min', np.min), ('max', np.max), ('median', np.median)]:
        print(f"  {label:<12}{fn(r):>14.5f}{fn(y):>14.5f}")
    print(f"  {'negatives':<12}{(r < 0).sum():>14d}{(y < 0).sum():>14d}")
    print(f"  per-slot mean correlation : "
          f"{np.corrcoef(r.mean(0), y.mean(0))[0, 1]:.4f}")
    print(f"  cells identical to real   : {identical} / {r.size}")
    if identical:
        raise SystemExit(f"REFUSING TO WRITE: {identical} cells of {name} "
                         f"reproduce a real value.")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--real', type=Path,
                    default=Path('instances/MER_LMP_Information.xlsx'),
                    help='the proprietary source workbook (read only)')
    ap.add_argument('--out', type=Path,
                    default=Path('instances/MER_LMP_Information_synthetic.xlsx'),
                    help='where to write the publishable synthetic workbook')
    args = ap.parse_args()

    if not args.real.exists():
        raise SystemExit(f"{args.real} not found. This file is proprietary and "
                         f"is not distributed with the repository; pass --real.")

    rng = np.random.default_rng(SEED)
    out = {}
    for sheet, clip in SHEETS.items():
        real_df = load_block(args.real, sheet)
        synth_df = synthesize(real_df, rng, clip_negative=clip)
        report(real_df, synth_df, sheet)
        out[sheet] = synth_df

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with pd.ExcelWriter(args.out, engine='openpyxl') as writer:
        for sheet, df in out.items():
            df.to_excel(writer, sheet_name=sheet)

    print(f"\nWrote {args.out}")
    print("Safe to publish: no real value is reproduced (checked above).")


if __name__ == '__main__':
    main()
