# PGO-skill Ledger — srad

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:49:07.057083+00:00 — srad
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.3260s -> 0.3271s (0.997x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS (byte-identical image_out.pgm) but 0.997x end-to-end (0.3260s -> 0.3271s); replaced the redundant per-thread division of the block-uniform (d_q0sqr*(1+d_q0sqr)) term with a single __shared__ reciprocal computed by thread 0 per block (same pattern validated on hotspot), plus shared the d_Jc reciprocal between its two uses. Addressed the dominant 48.2%-ratio/1.929x-estimated GPUStrengthReductionOptimizer finding on the srad kernel itself, but this app's total runtime is ~70% CUDA driver init/memory setup overhead and only ~4.6% actual compute (per the app's own timing breakdown) — even a real kernel-level win can't clear the noise floor end-to-end at this problem size.
