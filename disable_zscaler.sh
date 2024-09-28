#!/bin/bash

#  chmod +x disable_zscaler.sh
#  sudo ./disable_zscaler.sh

# Variables for Zscaler service files
ZSASERVICE_FILE="/etc/systemd/system/zsaservice.service"
ZSTUNNEL_FILE="/etc/systemd/system/zstunnel.service"

# Function to modify the service file
modify_service_file() {
  SERVICE_FILE=$1
  
  # Backup the original file
  echo "Backing up $SERVICE_FILE"
  sudo cp "$SERVICE_FILE" "$SERVICE_FILE.bak"
  
  # Comment out the ExecStart and add ConditionPathExists=false
  echo "Modifying $SERVICE_FILE"
  sudo sed -i 's/^ExecStart/#ExecStart/g' "$SERVICE_FILE"
  sudo sed -i '/^ExecStart/ a ConditionPathExists=false' "$SERVICE_FILE"
  
  # Comment out other unnecessary lines to ensure service doesn't restart
  sudo sed -i 's/^KillMode/#KillMode/g' "$SERVICE_FILE"
  sudo sed -i 's/^Restart/#Restart/g' "$SERVICE_FILE"
  sudo sed -i 's/^Type/#Type/g' "$SERVICE_FILE"
  sudo sed -i 's/^RestartSec/#RestartSec/g' "$SERVICE_FILE"
  sudo sed -i 's/^TimeoutStartSec/#TimeoutStartSec/g' "$SERVICE_FILE"
  sudo sed -i 's/^IgnoreSIGPIPE/#IgnoreSIGPIPE/g' "$SERVICE_FILE"
  sudo sed -i 's/^StandardOutput/#StandardOutput/g' "$SERVICE_FILE"
  sudo sed -i 's/^StandardError/#StandardError/g' "$SERVICE_FILE"
  sudo sed -i 's/^RemainAfterExit/#RemainAfterExit/g' "$SERVICE_FILE"

  echo "Modified $SERVICE_FILE"
}

# Modify zsaservice.service
modify_service_file "$ZSASERVICE_FILE"

# Modify zstunnel.service
modify_service_file "$ZSTUNNEL_FILE"

# Reload systemd to apply changes
echo "Reloading systemd daemon"
sudo systemctl daemon-reload

# Stop Zscaler services if they are running
echo "Stopping Zscaler services"
sudo systemctl stop zsaservice.service
sudo systemctl stop zstunnel.service

# Disable Zscaler services to prevent them from starting at boot
echo "Disabling Zscaler services from starting at boot"
sudo systemctl disable zsaservice.service
sudo systemctl disable zstunnel.service

echo "Zscaler services have been disabled."
