#!/usr/bin/env bash

set -euo pipefail

helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm dependency update spark-apps/