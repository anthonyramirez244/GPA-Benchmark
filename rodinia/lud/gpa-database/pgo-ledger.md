# PGO-skill Ledger — lud

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:37:12.805023+00:00 — lud
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2428s -> 0.2482s (0.978x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS but 0.978x end-to-end (0.2428s -> 0.2482s); replaced repeated shared-memory read-modify-write of peri_row[i][idx]/peri_col[idx][i] with a register accumulator in lud_perimeter's forward-substitution loops (addresses the dominant GINS:LAT_IDEP_SMEM blame at lines 140-143). Correctness-preserving but on this small 256x256 problem (~0.25s total, likely launch-overhead-dominated across many lud_perimeter invocations as offset advances) the win doesn't clear the noise floor.
