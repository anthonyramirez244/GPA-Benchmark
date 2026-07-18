# PGO-skill Ledger — nw

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:43:54.461050+00:00 — nw
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.2888s -> 0.2921s (0.989x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS but 0.989x end-to-end (0.2888s -> 0.2921s); prefetched the three matrix_cuda boundary loads (index_w/index_n/index_nw) in needle_cuda_shared_2 before the independent ref[] loop so their latency could overlap with it, addressing the dominant GPUCodeReorderOptimizer finding (65.2% ratio). Correctness-preserving but this benchmark's ~0.29s runtime is too fast/launch-overhead-dominated for the win to register.
