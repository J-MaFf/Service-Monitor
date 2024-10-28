$logFile = "serviceMonitor.log"

function Write-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry
}

$restartCounter = 0
$restartFailCounter = 0
while ($true) {
    $service = Get-Service -Name "WSearch"
    if ($service.Status -eq "Stopping") {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $message = "$timestamp - WSearch service is stopping. Attempting to restart..."
        Write-Host $message    # Write to console
        Write-Message $message # Write to log file

        try {
            # Attempt a graceful restart
            Restart-Service -Name "WSearch" -Force -ErrorAction Stop
        }
        catch {
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
        if ($service.Status -eq "Running") {
            $restartCounter++
            $message = "WSearch service restarted successfully. This was sucessful restart # $restartCounter."
            Write-Host $message
            Write-Message $message
        } else {
            $restartFailCounter++
            $message = "WSearch service failed to restart. This was failed restart # $restartFailCounter."
            Write-Host $message
            Write-Message $message
        }
    }

    # Sleep for a while before checking again
    Start-Sleep -Seconds 60
}