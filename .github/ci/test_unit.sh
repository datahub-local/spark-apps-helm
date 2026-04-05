#!/usr/bin/env bash

set -euo pipefail

CURRENT_DIR="$(dirname "$(realpath "$0")")"

helm plugin install https://github.com/helm-unittest/helm-unittest.git || true

helm unittest spark-apps