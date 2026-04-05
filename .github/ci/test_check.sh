#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="spark-apps"
TIMEOUT_SECONDS=600
POLL_SECONDS=5

print_debug_state() {
  echo "=== SparkApplications ==="
  kubectl get sparkapplications -n "$NAMESPACE" || true

  echo "=== Pods ==="
  kubectl get pods -n "$NAMESPACE" -o wide || true
}

print_pod_logs() {
  local pod_name="$1"

  echo "=== Pod description: $pod_name ==="
  kubectl describe pod "$pod_name" -n "$NAMESPACE" || true

  echo "=== Pod logs: $pod_name ==="
  kubectl logs "$pod_name" -n "$NAMESPACE" --all-containers=true || true
}

wait_for_sparkapplication_completed() {
  local app_name="$1"
  local end_time=$((SECONDS + TIMEOUT_SECONDS))

  echo "=== Waiting for SparkApplication $app_name to reach COMPLETED ==="
  while (( SECONDS < end_time )); do
    local app_state
    app_state="$(kubectl get sparkapplication "$app_name" -n "$NAMESPACE" -o jsonpath='{.status.applicationState.state}' 2>/dev/null || true)"

    if [[ "$app_state" == "COMPLETED" ]]; then
      echo "SparkApplication $app_name is COMPLETED"
      return 0
    fi

    sleep "$POLL_SECONDS"
  done

  echo "ERROR: SparkApplication $app_name did not reach COMPLETED within ${TIMEOUT_SECONDS}s"
  kubectl describe sparkapplication "$app_name" -n "$NAMESPACE" || true
  print_debug_state
  return 1
}

wait_for_completed_pod() {
  local app_name="$1"
  local pod_name="$2"
  local end_time=$((SECONDS + TIMEOUT_SECONDS))

  echo "=== Waiting for pod $pod_name for SparkApplication $app_name to complete ==="
  while (( SECONDS < end_time )); do
    local pod_phase
    local terminated_reason
    pod_phase="$(kubectl get pod "$pod_name" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
    terminated_reason="$(kubectl get pod "$pod_name" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[0].state.terminated.reason}' 2>/dev/null || true)"

    if [[ "$pod_phase" == "Succeeded" && "$terminated_reason" == "Completed" ]]; then
      echo "Pod $pod_name is Completed"
      return 0
    fi

    sleep "$POLL_SECONDS"
  done

  echo "ERROR: Pod $pod_name for SparkApplication $app_name did not reach Completed within ${TIMEOUT_SECONDS}s"
  print_pod_logs "$pod_name"
  print_debug_state
  return 1
}

mapfile -t spark_applications < <(kubectl get sparkapplications -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

if [[ ${#spark_applications[@]} -eq 0 ]]; then
  echo "ERROR: No SparkApplications found in namespace $NAMESPACE"
  print_debug_state
  exit 1
fi

for app_name in "${spark_applications[@]}"; do
  wait_for_sparkapplication_completed "$app_name"

  pod_name="$(kubectl get sparkapplication "$app_name" -n "$NAMESPACE" -o jsonpath='{.status.driverInfo.podName}' 2>/dev/null || true)"
  if [[ -z "$pod_name" ]]; then
    echo "ERROR: SparkApplication $app_name does not report a driver pod name"
    kubectl describe sparkapplication "$app_name" -n "$NAMESPACE" || true
    print_debug_state
    exit 1
  fi

  wait_for_completed_pod "$app_name" "$pod_name"
done

print_debug_state

echo "[✓] All tests passed!"
