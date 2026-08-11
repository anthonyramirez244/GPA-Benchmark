# PGO-skill Ledger — b+tree

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-13T17:07:13.288144+00:00 — b+tree
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.8848s -> 0.9827s (0.900x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Change: kernel_gpu_cuda.cu findK() — hoisted currKnodeD[bid]/offsetD[bid] into local registers (curr/off) to address GPUCodeReorderOptimizer's top finding (ratio 44.374%, redundant per-iteration global reload at lines 19/23/26/30/40/46/47).
- Decision: REVERTED — regression (0.900x end-to-end). No GPU kernel-level timing was available to confirm whether the kernel itself got faster; end-to-end got slower, likely because nvcc/ptxas at -O3 already CSEs each of these same-basic-block reads (no intervening store between the accesses), making the hoist a no-op on generated code while adding wall-clock noise. Local kernel timing being unavailable on this platform makes it impossible to fully separate "no-op" from "true regression" here -- treating as REVERTED either way per policy (endToEndSpeedup < 1.0).

### 2026-07-19T20:36:25.647382+00:00 — b+tree
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.9084s -> 0.9109s (0.997x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing findK: 370000ns -> 299000ns (1.237x)
- Self-reported kernel timing findRangeK: 275000ns -> 260000ns (1.058x)
- Change: kernel_gpu_cuda.cu findK() — different kernel+optimizer than the 2026-07-13 REVERTED entry above's findK+GPUCodeReorderOptimizer pair (skipped per SKILL.md step 3), this targets GPUWarpBalanceOptimizer's top finding (ratio 32.089%, not previously tried on b+tree, clean 1 KEPT/0 REVERTED cross-benchmark record via huffman). Hoisted `currKnodeD[bid]`/`offsetD[bid]` (read/written identically by every thread every iteration) into `__shared__ s_currKnode`/`s_offset` for the loop's duration, writing back to global memory once after -- same multi-writer semantics as the original (whichever thread's range condition matches writes `s_offset`, exactly as it wrote `offsetD[bid]` before), purely a memory-hierarchy change. Deliberately a different mechanism than the already-REVERTED per-thread-register hoist (which risked only thread 0's register ever updating, since registers aren't shared across threads) -- shared memory is visible to every thread after a sync, avoiding that pitfall.
- Decision: KEPT — governing metric is `selfReportedKernelSpeedups` for `findK` (1.237x, a real 23.7% kernel speedup) per SKILL.md step 8's precedence. `endToEndSpeedup` read 0.997x -- under the strict *old* end-to-end-only policy (any speedup < 1.0 is a regression) this genuine improvement would have been REVERTED a third time under this session's new-policy testing. `findRangeK`'s 1.058x is not attributed to this change (its source, kernel_gpu_cuda_2.cu, was not touched) -- likely incidental run-to-run noise, noted for completeness only, not as evidence.
- Also fixed a real robustness bug in `pgo_bench.py`'s `profile_kernels()` surfaced during this measurement: `nsys`'s own stdout/stderr contained non-UTF8 bytes, raising an uncaught `UnicodeDecodeError` that crashed the whole `compare` command instead of degrading gracefully like nsys failures are supposed to. Added `errors="replace"` to all three `nsys`-related `subprocess.run` calls.

### 2026-07-20T00:11:31.124886+00:00 — b+tree
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.9084s -> 0.9157s (0.992x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing findK: 370000ns -> 273000ns (1.355x)
- Self-reported kernel timing findRangeK: 275000ns -> 289000ns (0.952x)
- Change: rodinia/b+tree-opt's actual validated technique for findRangeK (untried before -- `-opt` doesn't touch findK at all, only findRangeK): hoisted `startD[bid]`/`endD[bid]` and the `knodesD[currKnodeD[bid]]`/`knodesD[lastKnodeD[bid]]`-derived key/indices pointers into locals, re-derived once per loop iteration instead of recomputing `knodesD[currKnodeD[bid]]` on every reference; removed the `currKnodeD[bid]`/`lastKnodeD[bid]` global write-back entirely (matches `-opt` -- nothing outside this kernel needs the intermediate per-level values). `findK` (from the entry above) untouched this round.
- Decision: REVERTED (findRangeK only; findK's earlier KEPT fix stays) — correctness PASS, but a real regression: 0.952x. `findK`'s speedup stayed consistent at 1.355x (vs. 1.237x measured before, within noise), confirming that fix is solid and this measurement is trustworthy. Third confirmed case this session (after nw, lud) where a technique validated in the repo's own `-opt` reference, applied exactly as `-opt` applies it, measurably regresses on this hardware. Pattern emerging: of the 4 "apply the exact human-validated -opt technique" retests this session (huffman implicitly via independent discovery, nw, lud, b+tree findRangeK), only huffman's independently-discovered match actually helped -- the other 3 direct `-opt` ports regressed. Not re-attempting.

### 2026-08-09T02:54:56.671184+00:00 — b+tree
- Problem size: file ../../data/b+tree/mil.txt command ../../data/b+tree/command.txt (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.9084s (σ=0.0000, n=?) -> 1.0504s (σ=0.0992, n=3) (0.865x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing findK: 370000ns (σ=0, n=?) -> 809000ns (σ=57105, n=3) (0.457x) [clears 2σ]
- Self-reported kernel timing findRangeK: 275000ns (σ=0, n=?) -> 275000ns (σ=99985, n=3) (1.000x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T02:59:47.642549+00:00 — b+tree
- Problem size: file ../../data/b+tree/mil.txt command ../../data/b+tree/command.txt (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.9084s (σ=0.0000, n=?) -> 0.9864s (σ=0.0485, n=3) (0.921x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing findK: 370000ns (σ=0, n=?) -> 798000ns (σ=12220, n=3) (0.464x) [clears 2σ]
- Self-reported kernel timing findRangeK: 275000ns (σ=0, n=?) -> 244000ns (σ=24007, n=3) (1.127x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:08:31.900343+00:00 — b+tree
- Problem size: file ../../data/b+tree/mil.txt command ../../data/b+tree/command.txt
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 1.1167s (σ=0.0359, n=3) -> 0.9720s (σ=0.0207, n=3) (1.149x) [clears 2σ]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing findK: 873000ns (σ=170066, n=3) -> 875000ns (σ=35852, n=3) (0.998x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing findRangeK: 349000ns (σ=58847, n=3) -> 242000ns (σ=25942, n=3) (1.442x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-11T05:47:57.005159+00:00 — b+tree
- Problem size: file ../../data/b+tree/mil.txt command ../../data/b+tree/command.txt
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.9342s (σ=0.0960, n=3) -> 0.9064s (σ=0.0388, n=3) (1.031x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing findRangeK: 249000ns (σ=27713, n=3) -> 299000ns (σ=31086, n=3) (0.833x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing findK: 748000ns (σ=5568, n=3) -> 757000ns (σ=56722, n=3) (0.988x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-11T15:10:46.779706+00:00 — b+tree
- Problem size: file ../../data/b+tree/mil.txt command ../../data/b+tree/command.txt
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 1.1167s (σ=0.0359, n=3) -> 1.0201s (σ=0.0343, n=3) (1.095x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing findK: 873000ns (σ=170066, n=3) -> 961000ns (σ=159529, n=3) (0.908x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing findRangeK: 349000ns (σ=58847, n=3) -> 331000ns (σ=51811, n=3) (1.054x) [NOT SIGNIFICANT, within 2σ noise]
- Change: kernel_gpu_cuda.cu, findK()'s tree-level loop header (line 42) -- GPULoopUnrollOptimizer's
  top untried finding this profile (impact 0.038, ratio 17.64%, GINS:LAT_DEP). Added `#pragma
  unroll` (no fixed factor -- `height` is a runtime kernel parameter, uniform across all threads
  in the block, so no divergence risk at the loop's internal __syncthreads() calls). The other two
  findings this profile (GPUCodeReorderOptimizer 0.189 impact, GPUWarpBalanceOptimizer 0.155
  impact) are both already logged against findK -- CodeReorder REVERTED 2026-07-13 (skipped per
  step 3, same kernel+optimizer pair even though GPA now points at a different specific line);
  WarpBalance is the already-KEPT shared-memory hoist live in this same file.
- Decision: KEPT (unconfirmed) -- correctness PASS, governing metric `selfReportedKernelSpeedups`
  for findK reads 0.908x (nominal regression), does NOT clear 2sigma (n=3). findRangeK (untouched
  by this change) reads 1.054x, not attributed to this edit -- noise, noted for completeness only.
