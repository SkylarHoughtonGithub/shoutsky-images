#!/bin/bash

# Define paths to YAML files
pvcPath="pvc.yml"
secretPath="secret.yml"
deploymentPath="deployment.yml"
servicePath="service.yml"

# Define kubectl function and alias
kubectl() {
    minikube kubectl -- "$@"
}
alias k=kubectl

init() {
    echo "Preparing env..."
    minikube stop
    minikube start
    echo "env started."
}

apply() {
    echo "Creating PostgreSQL resources..."
    kubectl apply -f "$pvcPath"
    kubectl apply -f "$secretPath"
    kubectl apply -f "$deploymentPath"
    kubectl apply -f "$servicePath"
    
    # podName=$(kubectl get pods -l app=postgres -o jsonpath="{.items[0].metadata.name}")
    # if [ -z "$podName" ]; then
    #     echo "No postgres pods found"
    #     exit 1
    # fi
    # podNamespace=$(kubectl get pods -l app=postgres -o jsonpath="{.items[0].metadata.namespace}")
    # podPort=$(kubectl get pods -l app=postgres -o jsonpath="{.items[0].spec.containers[0].ports[*].containerPort}")
    
    # echo "Setting up port forward"
    # sleep 1
    # kubectl port-forward -n "$podNamespace" "$podName" "$podPort:$podPort" &
    
    # echo "Testing port connection"
    # if nc -z localhost "$podPort" 2>/dev/null; then
    #     echo "Successfully connected to port $podPort."
    # else
    #     echo "Failed to connect to port $podPort."
    # fi
    
    echo "PostgreSQL resources created."
}

destroy() {
    echo "Destroying PostgreSQL resources..."
    kubectl delete -f "$servicePath"
    kubectl delete -f "$deploymentPath"
    kubectl delete -f "$secretPath"
    kubectl delete -f "$pvcPath"
    echo "PostgreSQL resources destroyed."
}

refresh() {
    echo "Destroying PostgreSQL resources..."
    destroy
    echo "PostgreSQL resources destroyed."
    echo "Creating PostgreSQL resources..."
    apply
    echo "PostgreSQL resources created."
}

show_usage() {
    echo "Usage: $0 <command>"
    echo "Commands:"
    echo "  init    - Prepare dev psql environment."
    echo "  create  - Create PostgreSQL resources"
    echo "  destroy - Destroy PostgreSQL resources"
    echo "  refresh - Destroy and Create PostgreSQL resources"
}

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

case "$1" in
    init)
        init
        ;;
    create)
        apply
        ;;
    destroy)
        destroy
        ;;
    refresh)
        refresh
        ;;
    *)
        echo "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac