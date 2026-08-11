# PGO-skill Ledger — hotspot

Append-only log of optimization attempts. Do not edit or delete past entries — only append.
Before proposing a new optimization, check here first for prior attempts on the same kernel + optimizer.

---

### 2026-07-01T19:21:37.954154+00:00 — hotspot
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.6186s -> 0.6118s (1.011x)
- Local kernel timing: unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Decision: KEPT — correctness PASS (byte-identical output.out), 1.011x end-to-end speedup (0.6186s -> 0.6118s); moved step_div_Cap/Rx_1/Ry_1/Rz_1 from per-thread-redundant divisions to a single __shared__ computation by thread (0,0) per block, reusing the kernel's existing __syncthreads() barrier.

### 2026-08-09T02:55:38.314037+00:00 — hotspot
- Problem size: 512 2 2 ../../data/hotspot/temp_512 ../../data/hotspot/power_512 output.out (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.5843s (σ=0.0000, n=?) -> 0.6594s (σ=0.0721, n=3) (0.886x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing calculate_temp: 506752ns (σ=0, n=?) -> 908992ns (σ=58555, n=3) (0.557x) [clears 2σ]

### 2026-08-09T03:00:28.868546+00:00 — hotspot
- Problem size: 512 2 2 ../../data/hotspot/temp_512 ../../data/hotspot/power_512 output.out (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.5843s (σ=0.0000, n=?) -> 0.6650s (σ=0.0141, n=3) (0.879x) [clears 2σ]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing calculate_temp: 506752ns (σ=0, n=?) -> 915936ns (σ=45801, n=3) (0.553x) [clears 2σ]

### 2026-08-09T03:03:16.929669+00:00 — hotspot
- Problem size: 512 2 2 ../../data/hotspot/temp_512 ../../data/hotspot/power_512 output.out (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.5843s (σ=0.0000, n=?) -> 0.6953s (σ=0.0154, n=3) (0.840x) [clears 2σ]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing calculate_temp: 506752ns (σ=0, n=?) -> 917472ns (σ=34321, n=3) (0.552x) [clears 2σ]

### 2026-08-09T03:03:27.537088+00:00 — hotspot
- Problem size: 512 2 2 ../../data/hotspot/temp_512 ../../data/hotspot/power_512 output.out (baseline was measured at: (unknown — predates problem-size tracking) — this is a deliberate different-size comparison, not a like-for-like retest; do not treat the speedup below as validating/invalidating the baseline's original problem size)
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.5843s (σ=0.0000, n=?) -> 0.6577s (σ=0.0301, n=3) (0.888x) [clears 2σ]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing calculate_temp: 506752ns (σ=0, n=?) -> 1047360ns (σ=126791, n=3) (0.484x) [clears 2σ]

### 2026-08-09T03:08:59.104852+00:00 — hotspot
- Problem size: 512 2 2 ../../data/hotspot/temp_512 ../../data/hotspot/power_512 output.out
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.6794s (σ=0.0188, n=3) -> 0.6605s (σ=0.0194, n=3) (1.029x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing calculate_temp: 934048ns (σ=52415, n=3) -> 962464ns (σ=25174, n=3) (0.970x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-11T05:47:00.404056+00:00 — hotspot
- Problem size: 512 2 2 ../../data/hotspot/temp_512 ../../data/hotspot/power_512 output.out
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.6268s (σ=0.0155, n=3) -> 0.6241s (σ=0.0208, n=3) (1.004x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing calculate_temp: 1009216ns (σ=85808, n=3) -> 1002624ns (σ=135785, n=3) (1.007x) [NOT SIGNIFICANT, within 2σ noise]

### 2026-08-11T06:04:45.049864+00:00 — hotspot
- Problem size: 512 2 2 ../../data/hotspot/temp_512 ../../data/hotspot/power_512 output.out
- Correctness: PASS (output matches golden reference exactly)
- End-to-end: 0.6794s (σ=0.0188, n=3) -> 0.6529s (σ=0.0151, n=3) (1.040x) [NOT SIGNIFICANT, within 2σ noise]
- Local kernel timing (nsys): unavailable (nsys captured no GPU kernel activity records on this platform (known limitation on some WSL2/driver combinations) -- end-to-end timing is still valid, local kernel timing is not)
- Self-reported kernel timing calculate_temp: 934048ns (σ=52415, n=3) -> 957632ns (σ=35838, n=3) (0.975x) [NOT SIGNIFICANT, within 2σ noise]
- Change: hotspot.cu `calculate_temp()`, lines 199-200 — `2.0*temp_on_cuda[ty][tx]` used a
  64-bit double literal against a 32-bit float operand inside the hottest per-iteration
  computation (`GINS:LAT_TMEM` dominant stall, ratio 26.902%, highest impactScore of any finding
  this profile: 0.098999). Per `GPUStrengthReductionOptimizer`'s own description point 2 ("a
  float constant by default is 64-bit... the compiler transforms the 32-bit value to a 64-bit
  value first"), changed both occurrences to `2.0f`, eliminating the implicit float->double->float
  promotion/demotion around the multiply. Genuinely untried finding -- the earlier hotspot fix
  (2026-07-01) targeted step_div_Cap/Rx_1/Ry_1/Rz_1 (a different GPUStrengthReductionOptimizer
  location), confirmed by reading pgo-ledger.md directly since the automated ledger-index couldn't
  attribute that entry (its prose never quoted the optimizer name literally).
- Decision: KEPT (unconfirmed) -- governing metric `selfReportedKernelSpeedups` for
  `calculate_temp` reads 0.975x (nominal regression), does NOT clear 2σ (n=3). Correctness holds.
  Keeping despite the nominal number because the change is a provable reduction in redundant work
  (fewer type-conversion instructions per iteration) independent of the unconfirmed timing --
  consistent with SKILL.md step 8's policy for this exact case. Not claiming a validated
  performance win without a larger-n retest.
