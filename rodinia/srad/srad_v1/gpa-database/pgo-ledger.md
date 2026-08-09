# PGO-skill Ledger — srad

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:49:07.057083+00:00 — srad
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.3260s -> 0.3271s (0.997x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS (byte-identical image_out.pgm) but 0.997x end-to-end (0.3260s -> 0.3271s); replaced the redundant per-thread division of the block-uniform (d_q0sqr*(1+d_q0sqr)) term with a single __shared__ reciprocal computed by thread 0 per block (same pattern validated on hotspot), plus shared the d_Jc reciprocal between its two uses. Addressed the dominant 48.2%-ratio/1.929x-estimated GPUStrengthReductionOptimizer finding on the srad kernel itself, but this app's total runtime is ~70% CUDA driver init/memory setup overhead and only ~4.6% actual compute (per the app's own timing breakdown) — even a real kernel-level win can't clear the noise floor end-to-end at this problem size.

### 2026-07-19T20:32:31.685551+00:00 — srad
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.3046s -> 0.3100s (0.982x)
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing extract: 528000ns -> 524000ns (1.008x)
- Self-reported kernel timing srad+srad2+prepare+reduce (combined COMPUTE stage): 17940000ns -> 17216999ns (1.042x)
- Self-reported kernel timing compress: 97000ns -> 54000ns (1.796x)
- Change: identical re-application of the 2026-07-01 entry's fix (this time scoped to just the block-uniform `d_q0sqr` term, not also the `d_Jc` part described in the old entry, which didn't have a clearly reconstructable second use in the current source) -- srad_kernel.cu's `srad()` kernel: added `__shared__ fp d_q0sqr_recip`, computed once by `tx==0` and `__syncthreads()`'d *before* the `ei<d_Ne` guard (so every thread in the block reaches the barrier, avoiding a divergent-__syncthreads hazard for blocks where some threads have `ei>=d_Ne`), replacing every thread's redundant `/ (d_q0sqr*(1+d_q0sqr))` division with a multiply by the precomputed reciprocal. `d_q0sqr` is a kernel parameter, identical for every thread -- re-tested specifically because the original REVERTED call predates local timing for this benchmark.
- Decision: KEPT — governing metric is `selfReportedKernelSpeedups` for `srad+srad2+prepare+reduce (combined COMPUTE stage)` (1.042x, a real 4.2% speedup) per SKILL.md step 8's updated precedence. `endToEndSpeedup` read 0.982x (a nominal regression) -- under the *old* end-to-end-only policy this would have stayed REVERTED a second time, this time wrongly. Caveat: this label is combined across 4 kernels (srad, srad2, prepare, reduce) and only `srad` was touched, so the 4.2% isn't proven to be 100% attributable to this specific edit, but it's still the best available signal and a real, non-trivial movement (unlike `compress`'s 1.796x swing, which I did NOT touch and attribute to noise given its tiny ~0.1ms absolute scale). Second confirmed case (after huffman) where the new governing-speedup policy reverses what the old end-to-end-only policy would have concluded.

### 2026-08-09T02:18:19.065723+00:00 — srad
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.3046s (σ=0.0000, n=?) -> 0.3500s (σ=0.0553, n=3) (0.870x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing extract: 528000ns (σ=0, n=?) -> 965000ns (σ=328526, n=3) (0.547x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing srad+srad2+prepare+reduce (combined COMPUTE stage): 17940000ns (σ=0, n=?) -> 16349001ns (σ=1473395, n=3) (1.097x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing compress: 97000ns (σ=0, n=?) -> 41000ns (σ=6557, n=3) (2.366x) [clears 2σ]
- Note: baseline side here (σ=0, n=?) predates the N-repeat stddev instrumentation added this
  session, so this comparison is a 3-sample-vs-1-sample mismatch, not yet a clean test. See the
  entry immediately below for a proper N=3-vs-N=3 re-measurement.

### 2026-08-09T02:19:43.044980+00:00 — srad (clean N=3-vs-N=3 re-measurement)
- Method: pre-fix `srad_kernel.cu` (commit 25361e2^) was temporarily swapped back in and
  `pgo_bench.py baseline srad` re-run to capture a fresh 3-sample baseline under the new
  stddev-aware code, then the KEPT fix (commit 25361e2) was restored and `compare` re-run --
  giving a real N=3-vs-N=3 comparison instead of the 1-sample-vs-3-sample mismatch above.
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.3764s (σ=0.0222, n=3) -> 0.3554s (σ=0.0168, n=3) (1.059x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (same WSL2 platform limitation as above)
- Self-reported kernel timing extract: 1046000ns (σ=134240, n=3) -> 964000ns (σ=27221, n=3) (1.085x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing compress: 39000ns (σ=8544, n=3) -> 37000ns (σ=1000, n=3) (1.054x) [NOT SIGNIFICANT, within 2σ noise]
- Self-reported kernel timing srad+srad2+prepare+reduce (combined COMPUTE stage): 16482000ns (σ=548207, n=3) -> 15296000ns (σ=352350, n=3) (1.078x) [NOT SIGNIFICANT, within 2σ noise]
- Decision: **KEPT, but downgrade confidence — statistically unconfirmed at n=3.** All three
  self-reported metrics now point the same direction (5-9% faster) with a clean, matched-sample
  comparison, and the fix is architecturally sound (register/shared-memory hoist of a
  provably block-uniform value, no correctness risk, byte-identical output both times). But none
  of the three clears the 2σ significance gate — the combined-COMPUTE-stage metric that
  originally justified KEPT came the closest (diff 1,186,000ns vs. threshold 1,303,600ns, ~91%
  of the way there) but still falls short. `compress`'s dramatic-looking 2.366x from the
  mismatched-sample comparison above completely evaporates to a mundane, also-not-significant
  1.054x once measured against a same-N baseline -- direct confirmation that the earlier
  apparent "significant" result was a sample-size artifact, not real signal. Not reverting: no
  evidence of regression either, and the code is a strict improvement in redundant-work terms
  even if not provably faster in wall-clock terms at this problem size and n=3. Recommend a
  future re-test at n=10+ if this benchmark's kernel-level number ever needs to be load-bearing
  for a paper claim -- 3 samples is enough to catch gross regressions but not enough to
  confidently confirm a ~5-9% effect against ~2-3% relative per-run noise. This is the case that
  motivated adding `SIGNIFICANCE_MULTIPLE`/`is_significant()` to `pgo_bench.py` in the first
  place (2026-08-08 session).
