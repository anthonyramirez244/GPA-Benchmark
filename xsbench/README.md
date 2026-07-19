# XSBench (CUDA)

Vendored from HeCBench's CUDA port (`src/xsbench-cuda`), BSD 3-Clause licensed:
https://github.com/zjin-lcf/HeCBench

Original benchmark: J. R. Tramm, A. R. Siegel, T. Islam, and M. Schulz, "XSBench -- The
Development and Verification of a Performance Abstraction for Monte Carlo Reactor Analysis,"
PHYSOR 2014. https://www.mcs.anl.gov/papers/P5064-0114.pdf

Added to this repo (not present in GPA-Benchmark upstream) as part of the ML-PGO project's
literature-survey requirement -- see `MyProject/papers.md` for the coverage check confirming this
kernel isn't already covered by GvProf, DrGPUM, or GPA's existing rodinia-based benchmark set.

Local changes from the HeCBench source: `Makefile`'s `ARCH` changed from `sm_60` to `sm_86`
(RTX 3070 is Ampere) and `-lineinfo` added to `CFLAGS` -- required for GPA's `hpcstruct`/`hpcprof`
to map advice back to real source file:line locations, same fix already applied to every other
benchmark in this repo.
