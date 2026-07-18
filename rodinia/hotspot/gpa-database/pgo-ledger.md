# PGO-skill Ledger — hotspot

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:21:37.954154+00:00 — hotspot
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.6186s -> 0.6118s (1.011x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: KEPT — correctness PASS (byte-identical output.out), 1.011x end-to-end speedup (0.6186s -> 0.6118s); moved step_div_Cap/Rx_1/Ry_1/Rz_1 from per-thread-redundant divisions to a single __shared__ computation by thread (0,0) per block, reusing the kernel's existing __syncthreads() barrier.
