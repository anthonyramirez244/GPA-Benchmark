# PGO-skill Ledger — kmeans

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:32:16.543600+00:00 — kmeans
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 3.9584s -> 4.1399s (0.956x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS but 0.956x end-to-end on this measurement (an earlier ad-hoc measurement showed 1.017x before this became the official ledger entry) — kmeans' ~4s runtime here is dominated by I/O loading the 494K-point kdd_cup dataset, so a small kernel-level win (addr strength reduction in kmeansPoint) is within run-to-run noise at 3 runs. Per policy, the officially logged compare result governs; reverted rather than cherry-picking the favorable run.

### 2026-07-20T00:13:26.799609+00:00 — kmeans
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.0320s -> 4.0427s (0.997x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1690304ns -> 1697472ns (0.996x)

### 2026-07-20T00:14:00.146780+00:00 — kmeans
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.0320s -> 3.9943s (1.009x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1690304ns -> 2032960ns (0.831x)

### 2026-07-20T00:14:34.167663+00:00 — kmeans
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.0320s -> 4.0364s (0.999x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1690304ns -> 1661600ns (1.017x)
- Change: `#pragma unroll 8` on kmeansPoint's `for (j=0; j < nfeatures; j++)` loop (kmeans_cuda_kernel.cu:89) -- matches both GPA's own fresh top finding (`GPULoopUnrollOptimizer`, 30.564% ratio, same line) and rodinia/kmeans-opt's validated technique exactly. First real GPA profile + attempt for kmeans this session.
- Decision: REVERTED -- three real `selfReportedKernelSpeedups` measurements this round (0.996x, 0.831x, 1.017x) swing too widely to trust any single one; no reliable signal either way. Consistent with the 2026-07-01 entry's own conclusion: kmeans' ~4s runtime here is dominated by loading the 494K-point kdd_cup dataset, so kmeansPoint's absolute kernel time (~1.7-2.0ms) is tiny and its single-sample self-reported timing (last-of-3-runs, not yet median-smoothed -- a known limitation noted 2026-07-19) is itself noisy at this scale. A fourth case in the "-opt-matching retest" set, and like nw/lud/b+tree-findRangeK, does not show a clean confirmed win despite matching both GPA's own advice and the human-validated reference exactly.

### 2026-08-09T02:56:11.721522+00:00 — kmeans
- Problem size: -o -i ../../data/kmeans/kdd_cup (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.0320s (σ=0.0000, n=?) -> 4.3781s (σ=0.4642, n=3) (0.921x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1690304ns (σ=0, n=?) -> 1661024ns (σ=84456, n=3) (1.018x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:01:01.927632+00:00 — kmeans
- Problem size: -o -i ../../data/kmeans/kdd_cup (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.0320s (σ=0.0000, n=?) -> 4.4376s (σ=0.0406, n=3) (0.909x) [clears 2σ]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1690304ns (σ=0, n=?) -> 1800128ns (σ=632809, n=3) (0.939x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:09:24.888509+00:00 — kmeans
- Problem size: -o -i ../../data/kmeans/kdd_cup
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.4970s (σ=0.0653, n=3) -> 4.4261s (σ=0.0344, n=3) (1.016x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1725440ns (σ=60566, n=3) -> 1665952ns (σ=70540, n=3) (1.036x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-11T05:50:36.830528+00:00 — kmeans
- Problem size: -o -i ../../data/kmeans/kdd_cup
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.1873s (σ=0.6464, n=3) -> 4.0865s (σ=0.0199, n=3) (1.025x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1694720ns (σ=190503, n=3) -> 1764256ns (σ=66935, n=3) (0.961x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-11T14:57:34.341300+00:00 — kmeans
- Problem size: -o -i ../../data/kmeans/kdd_cup
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 4.4970s (σ=0.0653, n=3) -> 4.7178s (σ=0.0719, n=3) (0.953x) [clears 2σ]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing kmeansPoint: 1725440ns (σ=60566, n=3) -> 1764640ns (σ=40663, n=3) (0.978x) [NOT SIGNIFICANT, within 2σ noise]
- Change: kmeans_cuda_kernel.cu, kmeansPoint()'s feature-distance loop (lines 89-95) --
  GPUCodeReorderOptimizer's top finding this profile (impact 0.122, ratio 34.45%,
  GINS:LAT_IDEP_WAR), a genuinely different fix than the already-REVERTED pragma-unroll-8
  attempt. Software-pipelined the tex1Dfetch load: issue iteration j+1's fetch before iteration
  j's diff*diff arithmetic, so the load latency overlaps with compute instead of stalling on it
  every iteration. Note: the fetched value (point_id + j*npoints) doesn't actually depend on the
  outer cluster loop `i` at all -- it's redundantly re-fetched from texture memory once per
  cluster -- but restructuring the loop nesting to cache it once per point is a bigger, riskier
  change outside GPA's specific "reorder, don't restructure" suggestion for this finding; left as
  a follow-up candidate, not attempted here.
- Decision: KEPT (unconfirmed) -- correctness PASS, governing metric `selfReportedKernelSpeedups`
  reads 0.978x (nominal regression), does NOT clear 2sigma (n=3). endToEndSpeedup reads 0.953x
  and IS flagged significant, but per SKILL.md step 8 precedence the kernel-level metric governs,
  not end-to-end. Keeping: the prefetch is a provable latency-hiding technique independent of the
  unconfirmed timing, and kmeans' own history (2026-07-20) already showed 3-run self-reported
  timing swinging widely (0.996x/0.831x/1.017x) on this benchmark's ~1.7ms kernel against a ~4.5s
  total runtime dominated by dataset I/O -- consistent with genuine measurement noise at this scale
  rather than a real regression.
