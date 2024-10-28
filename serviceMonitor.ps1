$logFile = "serviceMonitor.log"


<#
.SYNOPSIS
    Writes a message to a log file with a timestamp.

.DESCRIPTION
    The Write-Message function takes a string message as input, appends a timestamp to it, 
    and writes the resulting log entry to a specified log file.

.PARAMETER message
    The message to be logged.

.EXAMPLE
    Write-Message -message "Service started successfully"
    This will log an entry like "2023-03-15 14:23:45 - Service started successfully" to the log file.

.NOTES
    Ensure that the variable $logFile is defined and points to a valid file path before calling this function.
#>
function Write-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry
}

# Counter variables
$restartCounter = 0
$restartFailCounter = 0

# First time check
$service = Get-Service -Name "WSearch"
Write-Host "Initial status of WSearch service: $($service.Status)"
Write-Message "Initial status of WSearch service: $($service.Status)"

# Main loop
while ($true) {
    $service = Get-Service -Name "WSearch"
    if (-not $service.Status -eq "Running") { # If the service is not running
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $message = "$timestamp - WSearch service is stopping. Attempting to restart..."
        Write-Host $message    # Write to console
        Write-Message $message # Write to log file

        try { # Attempt a graceful restart
            Restart-Service -Name "WSearch" -Force -ErrorAction Stop
        }
        catch { # If the graceful restart fails
            $message = "Graceful restart failed. Forcefully stopping and restarting..."
            Write-Host $message
            Write-Message $message

            Stop-Service -Name "WSearch" -Force
            Start-Service -Name "WSearch"
        }

        # Wait for the service to start
        Start-Sleep -Seconds 10

        # Verify the service is running
        $service = Get-Service -Name "WSearch"
        if ($service.Status -eq "Running") { # If the service is running
            $restartCounter++
            $message = "WSearch service restarted successfully. This was sucessful restart # $restartCounter."
            Write-Host $message
            Write-Message $message
        } else { # If the service is not running
            $restartFailCounter++
            $message = "WSearch service failed to restart. This was failed restart # $restartFailCounter."
            Write-Host $message
            Write-Message $message
        }
    }

    # Sleep for a while before checking again
    Start-Sleep -Seconds 60
}