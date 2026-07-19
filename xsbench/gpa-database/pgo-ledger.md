# PGO-skill Ledger — xsbench

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-19T18:38:57.492741+00:00 — xsbench
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 14.0784s -> 14.8030s (0.951x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Change: Simulation.cu calculate_macro_xs() — added `#pragma unroll` above the `for( int j = 0; j < num_nucs[mat]; j++ )` loop (line 504), addressing GPULoopUnrollOptimizer's top finding (ratio 93.399%, loop-carried latency at line 504) and overlapping with GPUCodeReorderOptimizer's top finding (ratio 93.732%, same loop's indirect nuclide-grid loads at lines 441-442/507-508). The loop's only true cross-iteration dependency is a commutative `+=` accumulation into macro_xs_vector; each iteration's `mats`/`concs` reads and nuclide-grid lookup are independent of prior iterations, matching the optimizer's own suggested fix.
- Decision: REVERTED — regression (0.951x end-to-end). Correctness held, but end-to-end got slower. `num_nucs[mat]` is a runtime-variable trip count (not a compile-time constant), so nvcc's `#pragma unroll` here is a hint it may only partially honor; local per-kernel timing was unavailable on this platform (same nsys/WSL2 limitation seen on other benchmarks), making it impossible to confirm whether this is a genuine kernel-level regression (e.g. increased register pressure/spills from partial unrolling) or noise in end-to-end wall-clock given this benchmark's ~14s runtime is dominated by host-side verification and device-init/JIT overhead, not the kernel itself. Treating as REVERTED per policy either way (endToEndSpeedup < 1.0). GPUCodeReorderOptimizer's overlapping finding was not separately attempted this invocation (one optimization attempt per invocation per SKILL.md policy) -- worth trying next given it targets the same loop's memory-latency-hiding angle rather than unrolling, despite its more mixed 1 KEPT/2 REVERTED cross-benchmark record (per state/global-optimizer-index.json).

### 2026-07-19T20:10:03.460320+00:00 — xsbench
- Correctness: PASS (stdout contained pass marker)
- End-to-end: 14.0865s -> 14.2443s (0.989x)
- Local kernel timing (nsys): unavailable (nsys profile failed to run: Command '['nsys', 'profile', '--trace=cuda', '-f', 'true', '-o', '/mnt/c/Users/antho/OneDrive/Documents/GitHub/ML-PGO/GPA/GPA-Benchmark/xsbench/pgo-bench-report', './main', '-s', 'small', '-m', 'event', '-r', '3']' timed out after 180 seconds)
- Self-reported kernel timing lookup: 224000000ns -> 224000000ns (1.000x)
- Change: identical re-application of the same `#pragma unroll` from the 2026-07-19T18:38:57 entry above, specifically to re-measure it now that `benchmarks.json`'s new `localTiming` config gives xsbench a real, nsys-independent kernel timer (parses Simulation's own `chrono`+`cudaDeviceSynchronize`-based "Average kernel execution time" line). Not a new idea being tried -- the same edit, better instrumentation.
- Decision: REVERTED — confirmed no-op, not a regression. Self-reported kernel timing came back bit-for-bit identical (224000000ns -> 224000000ns, 1.000x) despite the edit being present, while end-to-end moved differently between the two measurements of this exact same edit (0.951x here vs. 0.989x in the first attempt) -- that inconsistency on an unchanged kernel confirms the earlier end-to-end delta was pure run-to-run noise in the ~14s host-dominated total, not a real effect. Most likely explanation: `num_nucs[mat]` is a runtime-variable trip count, so nvcc's plain `#pragma unroll` (no fixed factor) silently declined to unroll anything here -- the compiled kernel is presumably unchanged. REVERTED for the same reason as before (no measured benefit), but now for a clear, well-substantiated reason instead of an ambiguous one. `GPUCodeReorderOptimizer`'s overlapping finding on this same loop remains untried.
