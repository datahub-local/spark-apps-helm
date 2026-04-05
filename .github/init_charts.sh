#!/usr/bin/env bash

set -euo pipefail

for chart in charts/*/; do
  if [ -f "$chart/Chart.yaml" ]; then
    helm dependency update "$chart"
  fi
done