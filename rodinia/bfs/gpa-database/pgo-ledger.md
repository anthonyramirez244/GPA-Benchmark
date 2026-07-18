# PGO-skill Ledger — bfs

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-03T21:16:04.998437+00:00 — bfs
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 3.5158s -> 3.1538s (1.115x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Change: kernel.cu Kernel() — hoisted g_cost[tid] out of the edge loop into a register (`cost`), addressing GPUCodeReorderOptimizer's top finding (ratio 85.033%, redundant per-iteration reload at line 34); split the loop into a 4x-unrolled main loop plus scalar remainder, addressing GPULoopUnrollOptimizer (ratio 69.675%, line 29). Matches the repo's existing validated `bfs-opt/kernel.cu` reference variant.
- Decision: KEPT — 1.115x end-to-end speedup, correctness PASS. Local kernel speedup unavailable (nsys limitation).
