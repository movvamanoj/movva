#!/bin/bash

# This script is for Ubuntu 20.04 Focal Fossa to download and install XRDP with Enhanced Session Mode.
# Major thanks to: http://c-nergy.be/blog/?p=11336 for the tips.

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run with root privileges' >&2
    exit 1
fi

# Update system
apt update && apt upgrade -y

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "A reboot is required in order to proceed with the install." >&2
    echo "Please reboot and re-run this script to finish the install." >&2
    exit 1
fi

# Install necessary packages
apt install -y xrdp xorgxrdp linux-tools-virtual linux-cloud-tools-virtual

# Stop XRDP service
systemctl stop xrdp
systemctl stop xrdp-sesman

# Configure XRDP
sed -i_orig -e 's/port=3389/port=vsock:\/\/-1:3389/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini

# Create startubuntu.sh if it doesn't exist
if [ ! -e /etc/xrdp/startubuntu.sh ]; then
cat > /etc/xrdp/startubuntu.sh << EOF
#!/bin/sh
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
exec /etc/xrdp/startwm.sh
EOF
chmod a+x /etc/xrdp/startubuntu.sh
fi

# Use the script to setup the ubuntu session
sed -i_orig -e 's/startwm/startubuntu/g' /etc/xrdp/sesman.ini

# Rename the redirected drives to 'shared-drives'
sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini

# Change allowed_users in Xwrapper.config
sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

# Blacklist vmw_vsock_vmci_transport module
if [ ! -e /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf ]; then
  echo "blacklist vmw_vsock_vmci_transport" > /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf
fi

# Ensure hv_sock module gets loaded
if [ ! -e /etc/modules-load.d/hv_sock.conf ]; then
  echo "hv_sock" > /etc/modules-load.d/hv_sock.conf
fi

# Configure the policy xrdp session
cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# Reload and start XRDP service
systemctl daemon-reload
systemctl start xrdp
systemctl enable xrdp

echo "Install is complete."
echo "Reboot your machine to begin using XRDP."

# End of script
