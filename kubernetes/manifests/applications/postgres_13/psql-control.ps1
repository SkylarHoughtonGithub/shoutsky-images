# Define kubectl function and alias

# Define the paths to your YAML files
$pvcPath = "pvc.yml"
$secretPath = "secret.yml"
$deploymentPath = "deployment.yml"
$servicePath = "service.yml"
function kubectl { minikube kubectl -- $args }
if(!(Test-Path alias:k)) {New-Alias k kubectl}

function init {
    Write-Host "Preparing env..."
    minikube stop
    minikube start
    Write-Host "env started."
}
function port-forward {
    $podName = k get pods -l app=postgres -o jsonpath="{.items[0].metadata.name}"
    if ( -not $podName) {
        Write-Host "No postgres pods found"
        exit 1
    }
    $podNamespace = k get pods -l app=postgres -o jsonpath="{.items[0].metadata.namespace}"
    $podPort = k get pods -l app=postgres -o jsonpath="{.items[0].spec.containers[0].ports[*].containerPort}"
    Write-Host "Setting up port forward"
    sleep 1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "port forward failed."
        exit 1
    }
    Start-Process kubectl -ArgumentList  "port-forward -n $podNamespace $podName $podPort`:$podport" -NoNewWindow

    Write-Host "Testing port connection"
    $connectionTest = Test-NetConnection -ComputerName localhost -Port $podPort
    if ($connectionTest.TcpTestSucceeded) {
        Write-Host "Successfully connected to port $podPort."
    } 
    else {
        Write-Host "Failed to connect to port $podPort."
    }
}
function apply {
    Write-Host "Creating PostgreSQL resources..."
    k apply -f $pvcPath
    k apply -f $secretPath
    k apply -f $deploymentPath
    k apply -f $servicePath

    #TODO: add positional argument support to optionally setup port forwarding, toggle function here for now.
    # port-forward

    Write-Host "PostgreSQL resources created."
}

function destroy {
    Write-Host "Destroying PostgreSQL resources..."
    k delete -f $servicePath
    k delete -f $deploymentPath
    k delete -f $secretPath
    k delete -f $pvcPath
    Write-Host "PostgreSQL resources destroyed."
}

function refresh {
    Write-Host "Destroying PostgreSQL resources..."
    destroy
    Write-Host "PostgreSQL resources destroyed."
    Write-Host "Creating PostgreSQL resources..."
    apply
    Write-Host "PostgreSQL resources created."
}

function Show-Usage {
    Write-Host "Usage: .\psql-control.ps1 <command>"
    Write-Host "Commands:"
    Write-Host "  init    - Prepare dev psql environment."
    Write-Host "  create  - Create PostgreSQL resources"
    Write-Host "  create  - Create PostgreSQL resources"
    Write-Host "  destroy - Destroy PostgreSQL resources"
    Write-Host "  refresh - Destroy and Create PostgreSQL resources"
}

# Main script logic
if ($args.Count -eq 0) {
    Show-Usage
    exit
}

switch ($args[0]) {
    "init" {
        init
    }
    "create" {
        apply
    }
    "destroy" {
        destroy
    }
    "refresh" {
        refresh
    }
    default {
        Write-Host "Unknown command: $($args[0])"
        Show-Usage
    }
}
