# PGO-skill Ledger — lud

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:37:12.805023+00:00 — lud
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2428s -> 0.2482s (0.978x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS but 0.978x end-to-end (0.2428s -> 0.2482s); replaced repeated shared-memory read-modify-write of peri_row[i][idx]/peri_col[idx][i] with a register accumulator in lud_perimeter's forward-substitution loops (addresses the dominant GINS:LAT_IDEP_SMEM blame at lines 140-143). Correctness-preserving but on this small 256x256 problem (~0.25s total, likely launch-overhead-dominated across many lud_perimeter invocations as offset advances) the win doesn't clear the noise floor.

### 2026-07-19T20:30:04.109922+00:00 — lud
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2228s -> 0.2218s (1.005x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing lud_cuda (kernel+memcpy): 1917000ns -> 2026000ns (0.946x)
- Change: identical re-application of the 2026-07-01 entry's `peri_col` register-accumulator hoist in lud_perimeter (lines 139-144) -- re-tested specifically because the original REVERTED call was made with end-to-end only, before local timing existed for this benchmark.
- Decision: REVERTED — governing metric is `selfReportedKernelSpeedups` (0.946x, `lud_cuda (kernel+memcpy)` -- a combined/impure metric per SKILL.md step 7, includes the H2D/D2H `cudaMemcpy` calls alongside the kernel launches, not pure kernel-only time). Unlike xsbench/gaussian, this one **agrees** with the original 2026-07-01 call (both say regression) -- not every re-test disagrees with its historical end-to-end-only verdict; this is a useful confirming data point, not just a corrector. `endToEndSpeedup` read 1.005x (near-noise, would nominally look like a wash) -- governing metric still overrides it per policy. Not re-attempting; no other real finding at this problem size worth pursuing.

### 2026-07-20T00:09:54.843700+00:00 — lud
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2228s -> 0.2221s (1.003x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing lud_cuda (kernel+memcpy): 1917000ns -> 2416000ns (0.793x)
- Change: rodinia/lud-opt's actual validated technique -- same register-accumulator idea as the entry above, but applied to lud_diagonal (the kernel -opt actually applies it to) instead of lud_perimeter. `idx = threadIdx.x` cached once; both inner loops (the forward-substitution division loop and the row-update loop) accumulate into a local `s` instead of repeatedly read-modify-writing `shadow[idx][i]`/`shadow[i+1][idx]`, writing back once.
- Decision: REVERTED — correctness PASS, but a real regression: 0.793x, even worse than the peri_col attempt above (0.946x). Third confirmed case this session (after xsbench's no-op and nw's regression) where a technique validated in the repo's own `-opt` reference, applied exactly as `-opt` applies it, measurably does not help on this hardware (RTX 3070/Ampere) -- likely the same register-pressure/occupancy tradeoff seen elsewhere: this kernel's block is small (BLOCK_SIZE x 1 threads) and the extra register for `s` may cost more than the shared-memory re-reads it saves. Not re-attempting.
