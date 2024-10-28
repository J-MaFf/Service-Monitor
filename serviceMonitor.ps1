while ($true) {
    $service = Get-Service -Name "WSearch"
  
    if ($service.Status -eq "Stopping") {
      Write-Host "WSearch service is stopping. Attempting to restart..."
  
      try {
        # Attempt a graceful restart
        Restart-Service -Name "WSearch" -Force -ErrorAction Stop
      }
      catch {
        Write-Host "Graceful restart failed. Forcefully stopping and restarting..."
        Stop-Service -Name "WSearch" -Force
        Start-Service -Name "WSearch"
      }
  
      # Wait for the service to start
      Start-Sleep -Seconds 10
  
      # Verify the service is running
      $service = Get-Service -Name "WSearch"
      if ($service.Status -eq "Running") {
        Write-Host "WSearch service restarted successfully."
      } else {
        Write-Host "WSearch service failed to restart."
      }
    }
  
    Start-Sleep -Seconds 5
  }