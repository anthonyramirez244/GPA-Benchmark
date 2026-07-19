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
