# PGO-skill Ledger — gaussian

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-19T20:21:18.571816+00:00 — gaussian
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2463s -> 0.2420s (1.018x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Fan1+Fan2 (combined): 12305000ns -> 16662000ns (0.739x)
- Change: gaussian.cu Fan2() — hoisted `m_cuda[Size*(xidx+1+t)+t]` into a local `m_val` register, reused at both its line-310 use and its line-315 use (when `yidx==0`, `Size*(xidx+1+t)+(yidx+t)` is the identical address, so line 315 was reloading a value already read at line 310). Addressed GPUCodeReorderOptimizer's top finding (ratio 56.409%, line 310). Read-only value, no cross-thread synchronization involved, so this was a low-risk hoist by construction.
- Decision: REVERTED — kernel-level regression, despite a nominal end-to-end speedup. This is the mirror-image case of xsbench's REVERTED entry: there, self-reported timing showed a no-op masked by end-to-end noise; here, self-reported timing (Fan1+Fan2 combined) shows the kernel genuinely got 26% slower (12.305ms -> 16.662ms) while end-to-end happened to read 1.018x faster. Trusting end-to-end alone here would have logged this KEPT despite the actual optimization target measurably regressing -- exactly the failure mode the new `selfReportedKernelSpeedups` mechanism exists to catch. Most likely cause: adding `m_val` increased live register count in Fan2 (small, ~4x4 thread blocks across ~207 launches for this 208x208 matrix), which may have reduced occupancy or forced a spill, more than offsetting the one redundant global load removed. Not re-attempting this specific hoist; `GPUGlobalMemoryReductionOptimizer` (ratio 4.32%, much lower impact score) is the only other real finding and likely not worth pursuing at this problem size.
