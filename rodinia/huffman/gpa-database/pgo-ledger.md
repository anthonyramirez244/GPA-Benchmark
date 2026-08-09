# PGO-skill Ledger — huffman

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T18:37:11.453051+00:00 — huffman
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 0.2568s -> 0.2506s (1.025x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: KEPT (no-op verification run — confirms the stdout-marker correctness path and compare/ledger flow work for huffman).

### 2026-07-19T20:27:36.572175+00:00 — huffman
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 0.2285s -> 0.2422s (0.943x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing vlc_encode_kernel_sm64huff: 40685ns -> 31584ns (1.288x)
- Change: vlc_kernel_sm64huff.cu vlc_encode_kernel_sm64huff() — in the Blelloch parallel-scan down-sweep loop (line 106), split the per-iteration barrier: once `d <= 32` only warp 0 has any active thread (`k < d`), so replaced the unconditional block-wide `__syncthreads()` with `d <= 32 ? __syncwarp() : __syncthreads()`. `d` is identical across all threads every iteration, so the branch itself never diverges. Addressed GPUWarpBalanceOptimizer's top finding (ratio 43.217%, by far the highest impact score of any finding across every benchmark tested so far) — a `__syncthreads()` paid by every warp in the block while only one warp has real work, the textbook case that optimizer flags.
- Decision: KEPT — governing metric is `selfReportedKernelSpeedups` (1.288x, a real 28.8% kernel speedup), per SKILL.md step 8's updated precedence (self-reported kernel timing outranks end-to-end). `endToEndSpeedup` alone read 0.943x here -- under the *old* end-to-end-only policy this would have been wrongly REVERTED, exactly the failure mode that policy change exists to prevent. First real KEPT decision produced under the new governing-speedup policy.

### 2026-08-09T02:55:45.951351+00:00 — huffman
- Problem size: ../../data/huffman/test1024_H2.206587175259.in (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 0.2285s (σ=0.0000, n=?) -> 0.2775s (σ=0.0422, n=3) (0.823x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing vlc_encode_kernel_sm64huff: 40685ns (σ=0, n=?) -> 29734ns (σ=2794, n=3) (1.368x) [clears 2σ]

### 2026-08-09T03:00:36.584631+00:00 — huffman
- Problem size: ../../data/huffman/test1024_H2.206587175259.in (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 0.2285s (σ=0.0000, n=?) -> 0.2942s (σ=0.0162, n=3) (0.777x) [clears 2σ]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing vlc_encode_kernel_sm64huff: 40685ns (σ=0, n=?) -> 28643ns (σ=8876, n=3) (1.420x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:08:39.572875+00:00 — huffman
- Problem size: ../../data/huffman/test1024_H2.206587175259.in
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 0.3242s (σ=0.0171, n=3) -> 0.2934s (σ=0.0185, n=3) (1.105x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing vlc_encode_kernel_sm64huff: 36230ns (σ=12732, n=3) -> 28048ns (σ=13822, n=3) (1.292x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:33:30.612195+00:00 — huffman (clean N=3-vs-N=3 re-measurement)
- Method: same technique used for srad's Phase 1 retest and nw/lud's Phase 2 retests -- pre-fix
  `vlc_kernel_sm64huff.cu` (commit acc391b^) was temporarily swapped back in and
  `pgo_bench.py baseline huffman` re-run to capture a fresh 3-sample baseline, then the KEPT fix
  (commit acc391b) was restored and `compare` re-run. Prompted by a user-requested Agent-vs-Human
  (`-opt` reference) comparison exercise that measured this kernel fresh and got a materially
  different number than the original 2026-07-19 claim -- this is the follow-up formal retest.
- Problem size: ../../data/huffman/test1024_H2.206587175259.in
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 0.2851s (σ=0.0160, n=3) -> 0.2802s (σ=0.0276, n=3) (1.017x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing vlc_encode_kernel_sm64huff: 28480ns (σ=2484, n=3) -> 27363ns (σ=10716, n=3) (1.041x) [NOT SIGNIFICANT, within 2σ noise]
- Decision: KEPT (unconfirmed) — statistically unconfirmed at n=3, same downgrade applied to
  srad. The original 2026-07-19 KEPT verdict rested on a single-sample-vs-single-sample point
  comparison (40685ns -> 31584ns, 1.288x) with no variance estimate at all. This clean
  matched-sample (N=3 vs N=3) re-measurement shows the kernel is close to flat (1.041x) and does
  not clear the 2σ significance gate -- nowhere near the originally claimed 28.8% speedup.
  Correctness still holds and there's no significant regression either, and the code change
  itself remains defensible on first-principles grounds (replacing an unconditional block-wide
  `__syncthreads()` with a warp-scoped `__syncwarp()` once only one warp has real work is a
  legitimate reduction in synchronization scope, not a speculative hack) -- so not reverting, but
  the "real 28.8% kernel speedup" claim in the 2026-07-19 entry and in this project's prior
  session notes / ML-PGO.md should be read as unconfirmed going forward, not a validated result.
  This is the third case this session (after srad, alongside nw/lud's REVERTED-at-default-size
  entries) where a single-sample-era verdict didn't survive a fresh N=3 remeasurement -- see
  report.md's Agent-vs-Human comparison entry for the full context, including that the human
  `-opt` reference kernel itself also shows no significant speedup on this hardware (0.982x,
  not significant) when measured the same way.
