# Synthetic energy-cost data

`MER_LMP_Information_synthetic.xlsx` is a **synthetic** stand-in for the
marginal-emissions-rate (MER) and locational-marginal-price (LMP) workbook used
in this group's earlier eVTOL scheduling work. The real workbook is proprietary
and is not distributed.

## Coverage

Full: **11 cities x 144 ten-minute time slots** (10 to 1440 minutes) per sheet,
1584 values each, matching the real data block exactly in shape and labels.

The real workbook also carries a trailing "Averages" section. That section is
deliberately **not** reproduced: those cells are aggregates of the real
readings, so copying them would disclose real values, and recomputing them from
synthetic data would make them inconsistent with the real ones anyway.

## How it was produced

`gen_synthetic_mer_lmp.py`, seed 42, deterministic. Per sheet:

1. Take the per-time-slot mean across cities (the diurnal profile).
2. Subtract it, leaving each city's residual deviation.
3. Fit the inter-city covariance of the residuals; take its Cholesky factor `L`.
4. Emit `synthetic[:, k] = col_mean[k] + L @ z`, with `z ~ N(0, I)`.

LMP is clipped at zero (a price cannot be negative; the real series never
approaches zero, so this does not bind). MER is **not** clipped, because the
real emissions rate is genuinely negative at times and clipping would erase
that feature.

## What was verified

Checked against the real workbook by an independent reader, cell by cell:

| Check | LMP | MER |
|---|---|---|
| Data cells reproducing a real value | **0 / 1584** | **0 / 1584** |
| mean (real -> synthetic) | 15.25231 -> 15.25231 | 0.05801 -> 0.05801 |
| std | 6.22343 -> 5.12571 | 0.05838 -> 0.05512 |
| min | 3.85961 -> 4.82428 | -0.20237 -> -0.26388 |
| max | 33.03367 -> 25.46785 | 0.38714 -> 0.24963 |
| negative values | 0 -> 0 | 227 -> 145 |
| per-time-slot mean correlation | 1.0000 | 1.0000 |

The generator refuses to write the file if any cell matches a real value.

## What this discloses

By construction the per-time-slot means are reproduced *exactly*, and the
inter-city covariance is approximated. **Those aggregate statistics are
disclosed on purpose** -- that is what makes the surrogate useful. No
individual real reading is reproduced. If even aggregate disclosure is
unacceptable for your use, do not publish this file.

Tails are somewhat compressed relative to the real data (a Gaussian surrogate
does not reproduce the real extremes: LMP max 25.5 vs 33.0), so the file is
suitable for structural and pipeline testing, not for extreme-value analysis.

## Note on an earlier version

An earlier generator hardcoded a 7 x 18 block and scaled the noise by
`col_mean / mean_std`. At full coverage that inflated LMP variance by roughly
2x and, with an unconditional clip at zero, pinned 10-19% of cells to exactly
0, destroying all 227 real MER negatives. The current script separates the
diurnal mean from the residual covariance, which is what makes the
second-order claim actually hold.

## Relationship to the solver

Nothing in this repository reads this workbook. The `&cumu` propagator and the
example encodings do not use energy costs. The file is included so that the
energy-cost side of the wider project can be reproduced without access to the
proprietary source.

## Regenerating

Requires the proprietary source workbook (not distributed here) plus `numpy`,
`pandas` and `openpyxl`:

```bash
python instances/gen_synthetic_mer_lmp.py --real path/to/MER_LMP_Information.xlsx
```
