#!/usr/bin/env bash

set -euo pipefail

CURRENT_DIR="$(dirname "$(realpath "$0")")"

helm unittest spark-apps