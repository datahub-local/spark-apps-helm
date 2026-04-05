#!/usr/bin/env bash

set -euo pipefail

CURRENT_DIR="$(dirname "$(realpath "$0")")"

NAMESPACE="spark-apps"

helm upgrade --install --create-namespace --namespace "$NAMESPACE" \
  --values $CURRENT_DIR/ci-values.yaml spark-apps spark-apps