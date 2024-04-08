#!/bin/bash

# Function to check if a single pod is running
is_pod_running() {
  [[ $(kubectl get pod "$1" -n argocd -o 'jsonpath={.status.phase}') == "Running" ]]
}

sleep 15
while true; do
  all_running=true

  # Get a list of all ArgoCD pod names
  pod_names=$(kubectl get pods -n argocd -o 'jsonpath={.items[*].metadata.name}')

  # Iterate through pods and check for running status
  for pod in $pod_names; do
    if ! is_pod_running "$pod"; then
      all_running=false
      echo "Waiting for pod $pod to be Running..."
    fi
  done

  # All pods are Running 
  if $all_running; then
    echo "All ArgoCD pods are Running!"
    break
  fi

  sleep 5 # Adjust the sleep interval as needed
done
