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

### 2026-07-20T00:08:02.283996+00:00 — gaussian
- Correctness: FAIL (1 differing/missing line(s) vs golden stdout reference)
- End-to-end: 0.2463s -> 0.2490s (0.989x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Fan1+Fan2 (combined): 12305000ns -> 11661000ns (1.055x)
- Change: gaussian-opt reference's actual technique -- `#define BLOCK_SIZE_XY` changed from 4 to 8 (larger 2D thread block for Fan2, an occupancy/launch-config change, not a code-level fix). Tested directly since it's a completely different approach than the redundant-load hoist tried above.
- Decision: REVERTED — correctness FAIL (1 differing line vs golden reference), immediate revert per policy. The kernel-level number looked promising (1.055x) but is irrelevant once correctness fails. The grid/block-size ceiling-division math in ForwardSub() looks logically equivalent to gaussian-opt's own version (just parenthesized differently), so the break isn't an obvious off-by-one there -- root cause not fully diagnosed, likely something in Fan2 itself that only surfaces at an 8x8 block. Not re-attempting without a real correctness fix first; `-opt`'s validated speedup does not transfer to our vendored copy as a drop-in single-line change.

### 2026-08-09T02:55:27.664789+00:00 — gaussian
- Problem size: -f ../../data/gaussian/matrix208.txt (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2463s (σ=0.0000, n=?) -> 0.2994s (σ=0.0434, n=3) (0.823x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Fan1+Fan2 (combined): 12305000ns (σ=0, n=?) -> 13692000ns (σ=831483, n=3) (0.899x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:00:18.359246+00:00 — gaussian
- Problem size: -f ../../data/gaussian/matrix208.txt (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2463s (σ=0.0000, n=?) -> 0.2931s (σ=0.0263, n=3) (0.840x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Fan1+Fan2 (combined): 12305000ns (σ=0, n=?) -> 14076000ns (σ=1259786, n=3) (0.874x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:08:48.561041+00:00 — gaussian
- Problem size: -f ../../data/gaussian/matrix208.txt
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 0.2976s (σ=0.0279, n=3) -> 0.2975s (σ=0.0218, n=3) (1.001x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Fan1+Fan2 (combined): 13005000ns (σ=990786, n=3) -> 13664000ns (σ=288437, n=3) (0.952x) [NOT SIGNIFICANT, within 2σ noise]
