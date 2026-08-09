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
