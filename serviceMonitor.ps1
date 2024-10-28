$logFile = "serviceMonitor.log"

function Write-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry
}

while ($true) {
    $service = Get-Service -Name "WSearch"
  
    if ($service.Status -eq "Stopping") {
        $message = "WSearch service is stopping. Attempting to restart..."
        Write-Host $message    # Write to console
        Write-Message $message # Write to log file
  
        try {
            # Attempt a graceful restart
            Restart-Service -Name "WSearch" -Force -ErrorAction Stop
        }
        catch {
            $message = "Graceful restart failed. Forcefully stopping and restarting..."
            Write-Host $message
            Log-Message $message

            Stop-Service -Name "WSearch" -Force
            Start-Service -Name "WSearch"
        }
  
        # Wait for the service to start
        Start-Sleep -Seconds 10
  
        # Verify the service is running
        $service = Get-Service -Name "WSearch"
        if ($service.Status -eq "Running") {
            $message = "WSearch service restarted successfully."
            Write-Host $message
            Log-Message $message
        } else {
            $message = "WSearch service failed to restart."
            Write-Host $message
            Log-Message $message
        }
    }
}