#!/usr/bin/env bash
# Fixed-workload GPU benchmark runner (A/B across the unlock transaction).
# Usage: run_bench.sh <tag>   -> writes bench/<tag>.txt + clock snapshot
set -euo pipefail
TAG="${1:?usage: run_bench.sh <tag>}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$HERE/$TAG.txt"
BDF=0000:01:00.0
{
  echo "== run $(date -u +%FT%TZ) tag=$TAG =="
  echo "== clock/power pre =="
  nvidia-smi -q -d CLOCK,POWER,TEMPERATURE,PERFORMANCE | grep -E 'GPU Clocks|Graphics [0-9]|SM [0-9]|Memory [0-9]|Video [0-9]|GPU Current|Max Clocks|P-State|Power Draw|GPU Temp|Perf' | head -30
  echo "power_state: $(cat /sys/bus/pci/devices/$BDF/power_state)"
  echo "== run =="
  "$HERE/gemm_bench"
  echo "== clock/power post =="
  nvidia-smi -q -d CLOCK,POWER,TEMPERATURE,PERFORMANCE | grep -E 'GPU Clocks|Graphics [0-9]|SM [0-9]|Memory [0-9]|Video [0-9]|GPU Current|Max Clocks|P-State|Power Draw|GPU Temp|Perf' | head -30
  echo "power_state: $(cat /sys/bus/pci/devices/$BDF/power_state)"
} > "$OUT" 2>&1
cat "$OUT"
