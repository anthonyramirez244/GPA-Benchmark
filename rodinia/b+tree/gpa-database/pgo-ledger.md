# PGO-skill Ledger — b+tree

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-13T17:07:13.288144+00:00 — b+tree
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.8848s -> 0.9827s (0.900x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Change: kernel_gpu_cuda.cu findK() — hoisted currKnodeD[bid]/offsetD[bid] into local registers (curr/off) to address GPUCodeReorderOptimizer's top finding (ratio 44.374%, redundant per-iteration global reload at lines 19/23/26/30/40/46/47).
- Decision: REVERTED — regression (0.900x end-to-end). No GPU kernel-level timing was available to confirm whether the kernel itself got faster; end-to-end got slower, likely because nvcc/ptxas at -O3 already CSEs each of these same-basic-block reads (no intervening store between the accesses), making the hoist a no-op on generated code while adding wall-clock noise. Local kernel timing being unavailable on this platform makes it impossible to fully separate "no-op" from "true regression" here -- treating as REVERTED either way per policy (endToEndSpeedup < 1.0).
