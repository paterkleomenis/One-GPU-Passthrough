  GNU nano 8.1                                      /etc/libvirt/hooks/qemu.d/win10/release/end/revert.sh                                                
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
set -x

# Re-Bind GPU to Nvidia Driver
virsh nodedev-reattach pci_0000_01_00_0
virsh nodedev-reattach pci_0000_01_00_1

sleep 2

# Reload nvidia modules
modprobe -r vfio-pci
modprobe  nvidia
modprobe  nvidia_modeset
modprobe  nvidia_uvm
modprobe  nvidia_drm

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
# Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
#echo 1 > /sys/class/vtconsole/vtcon1/bind

nvidia-xconfig --query-gpu-info > /dev/null 2>&1
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Restart Display Manager
systemctl start display-manager.service
