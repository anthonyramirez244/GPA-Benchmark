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
