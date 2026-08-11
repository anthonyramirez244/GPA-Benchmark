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

### 2026-08-09T02:55:18.755506+00:00 — bfs
- Problem size: ../../data/bfs/graph1MW_6.txt
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 3.2729s (σ=0.4414, n=3) -> 3.2050s (σ=0.0256, n=3) (1.021x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Kernel+Kernel2 (combined): 2636064ns (σ=131056, n=3) -> 2520480ns (σ=223672, n=3) (1.046x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-09T03:00:09.532382+00:00 — bfs
- Problem size: ../../data/bfs/graph1MW_6.txt
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 3.2729s (σ=0.4414, n=3) -> 3.2517s (σ=0.0096, n=3) (1.007x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Kernel+Kernel2 (combined): 2636064ns (σ=131056, n=3) -> 2483712ns (σ=271698, n=3) (1.061x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-11T05:45:31.900939+00:00 — bfs
- Problem size: ../../data/bfs/graph1MW_6.txt
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 3.1194s (σ=1.2608, n=3) -> 3.0351s (σ=0.0341, n=3) (1.028x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing Kernel+Kernel2 (combined): 2594016ns (σ=41001, n=3) -> 3143520ns (σ=347221, n=3) (0.825x) [NOT SIGNIFICANT, within 2σ noise]
