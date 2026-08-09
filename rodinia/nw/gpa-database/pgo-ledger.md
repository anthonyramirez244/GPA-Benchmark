# PGO-skill Ledger — nw

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:43:54.461050+00:00 — nw
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.2888s -> 0.2921s (0.989x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS but 0.989x end-to-end (0.2888s -> 0.2921s); prefetched the three matrix_cuda boundary loads (index_w/index_n/index_nw) in needle_cuda_shared_2 before the independent ref[] loop so their latency could overlap with it, addressing the dominant GPUCodeReorderOptimizer finding (65.2% ratio). Correctness-preserving but this benchmark's ~0.29s runtime is too fast/launch-overhead-dominated for the win to register.

### 2026-07-20T00:06:54.356218+00:00 — nw
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.2700s -> 0.2806s (0.962x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing needle_cuda_shared_1: 3815200ns -> 2797888ns (1.364x)
- Self-reported kernel timing needle_cuda_shared_2: 1183680ns -> 1309312ns (0.904x)
- Change: identical re-application of the 2026-07-01 entry's prefetch fix in needle_cuda_shared_2 -- re-tested specifically because it exactly matches rodinia/nw-opt's validated reference implementation, and the original REVERTED call had no kernel-level data to confirm whether it was a real regression or just noise.
- Decision: REVERTED — confirmed real regression, not noise. Governing metric is `selfReportedKernelSpeedups` for `needle_cuda_shared_2` (the kernel actually touched): 0.904x, a genuine ~10% slowdown. `needle_cuda_shared_1` (untouched by this change) showed 1.364x in the same run -- unrelated run-to-run variance, not evidence of anything, since its source was never modified. This is a notable result: unlike xsbench/gaussian/huffman/srad/b+tree, this is a case where a technique that is validated and human-approved in the repo's own `-opt` reference genuinely does not help on this hardware (RTX 3070/Ampere) at this problem size -- "validated somewhere" does not mean "validated here." The original 2026-07-01 REVERTED verdict turns out to have been right, just not for the reason stated at the time (it blamed launch-overhead noise; the real cause is that the fix itself doesn't help on this GPU).

### 2026-08-09T02:30:34.216425+00:00 — nw (Phase 2: retest at 4x problem size)
- Problem size: 8192 10 (baseline was measured at: 8192 10 — matched-size retest; original two
  entries above were both measured at "2048 10")
- Method: the 2026-07-01/2026-07-20 fix was never committed to git (applied, measured, reverted
  within-session each time), so there was no diff to `git apply` -- reconstructed it from the
  ledger's own description ("prefetched the three matrix_cuda boundary loads... before the
  independent ref[] loop") by moving `needle_cuda_shared_2`'s three `temp[...] = matrix_cuda[...]`
  loads (lines 136-146) ahead of the `ref[ty][tx] = referrence[...]` loop (lines 131-134),
  preserving the same `__syncthreads()` placement relative to each load group. `benchmarks.json`'s
  `runCmd` temporarily changed from `["./needle", "2048", "10"]` to `["./needle", "8192", "10"]`
  (4x linear matrix size) for this retest only, then restored.
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.9848s (σ=0.1140, n=3) -> 1.0508s (σ=0.0547, n=3) (0.937x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing needle_cuda_shared_1: 7712032ns (σ=2418044, n=3) -> 7068608ns (σ=449769, n=3) (1.091x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing needle_cuda_shared_2: 6089728ns (σ=1783587, n=3) -> 6052864ns (σ=261228, n=3) (1.006x) [NOT SIGNIFICANT, within 2σ noise]
- Decision: KEPT (unconfirmed) at this problem size — does NOT reverse the 2026-07-20 REVERTED
  verdict at "2048 10" (that entry stays as-is; both are valid, size-specific results). But the
  picture changed materially: at 2048, `needle_cuda_shared_2` showed a governing, *significant*-by-
  inspection ~10% regression (0.904x). At 8192 (4x linear size), the same code change on the same
  kernel measures at 1.006x — statistically flat, not a regression and not a win. This is
  consistent with the regression being a fixed per-invocation overhead (extra `__syncthreads()`
  scheduling / instruction-issue reordering cost) that doesn't scale with problem size, so it
  shows up as a proportionally larger hit at the small default size and gets diluted into noise
  once the kernel does more real work per invocation. Not proposing to KEPT-and-ship this at the
  default "2048 10" size — the REVERTED verdict there is unaffected — but this is a concrete
  example of the exact failure mode the user flagged: a REVERTED verdict at one size is not
  evidence the technique "doesn't work," only that it doesn't help *at that size*. If nw's default
  problem size is ever revisited upward for other reasons, this technique is worth reconsidering
  rather than treated as permanently closed. See report.md Phase 2 for the cross-benchmark
  context (this was one of 2-3 REVERTED entries retested at scale this session).

### 2026-08-09T02:56:28.327689+00:00 — nw
- Problem size: 2048 10 (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.2700s (σ=0.0000, n=?) -> 0.3141s (σ=0.0322, n=3) (0.859x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing needle_cuda_shared_1: 3815200ns (σ=0, n=?) -> 2247520ns (σ=58767, n=3) (1.698x) [clears 2σ]
- Self-reported kernel timing needle_cuda_shared_2: 1183680ns (σ=0, n=?) -> 1201152ns (σ=10293, n=3) (0.985x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:01:10.785080+00:00 — nw
- Problem size: 2048 10 (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.2700s (σ=0.0000, n=?) -> 0.3138s (σ=0.0260, n=3) (0.860x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing needle_cuda_shared_1: 3815200ns (σ=0, n=?) -> 2386048ns (σ=192579, n=3) (1.599x) [clears 2σ]
- Self-reported kernel timing needle_cuda_shared_2: 1183680ns (σ=0, n=?) -> 1335296ns (σ=66689, n=3) (0.886x) [clears 2σ]
