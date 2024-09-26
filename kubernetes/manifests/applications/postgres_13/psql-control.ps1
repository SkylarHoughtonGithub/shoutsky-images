# Define kubectl function and alias

# Define the paths to your YAML files
$pvcPath = "pvc.yml"
$secretPath = "secret.yml"
$deploymentPath = "deployment.yml"
$servicePath = "service.yml"
function kubectl { minikube kubectl -- $args }
New-Alias k kubectl

function init {
    Write-Host "Preparing env..."
    minikube stop
    minikube start
    Write-Host "env started."
}
function apply {
    Write-Host "Creating PostgreSQL resources..."
    k apply -f $pvcPath
    k apply -f $secretPath
    k apply -f $deploymentPath
    k apply -f $servicePath
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
    k delete -f $servicePath
    k delete -f $deploymentPath
    k delete -f $secretPath
    k delete -f $pvcPath
    Write-Host "PostgreSQL resources destroyed."
    Write-Host "Creating PostgreSQL resources..."
    k apply -f $pvcPath
    k apply -f $secretPath
    k apply -f $deploymentPath
    k apply -f $servicePath
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
