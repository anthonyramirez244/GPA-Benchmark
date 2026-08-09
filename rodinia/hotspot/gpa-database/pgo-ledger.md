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
