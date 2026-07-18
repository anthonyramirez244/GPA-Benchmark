# PGO-skill Ledger — kmeans

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:32:16.543600+00:00 — kmeans
- Correctness: PASS (stdout (minus ignored/non-deterministic lines) matches golden reference exactly)
- End-to-end: 3.9584s -> 4.1399s (0.956x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: REVERTED — correctness PASS but 0.956x end-to-end on this measurement (an earlier ad-hoc measurement showed 1.017x before this became the official ledger entry) — kmeans' ~4s runtime here is dominated by I/O loading the 494K-point kdd_cup dataset, so a small kernel-level win (addr strength reduction in kmeansPoint) is within run-to-run noise at 3 runs. Per policy, the officially logged compare result governs; reverted rather than cherry-picking the favorable run.
