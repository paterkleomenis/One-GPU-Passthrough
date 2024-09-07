## Overview

This repository provides a comprehensive guide to setting up **GPU passthrough** on Linux systems. GPU passthrough allows a virtual machine (VM) to directly access the host's GPU, enabling high-performance graphics rendering in a VM environment. This is particularly useful for tasks like gaming, 3D rendering, and running GPU-intensive applications in a virtualized setup.

## Contents

- **Step-by-Step Setup Guides**
  - Detailed instructions for various Linux distributions
  - Configuration files and scripts
- **Troubleshooting**
  - Common issues and solutions
  - Tips for hardware compatibility
- **Performance Optimization**
  - Tweaks to maximize GPU performance
  - Best practices for virtualization settings
- **Resources**
  - Links to useful tools and external tutorials
  - Community forums and support channels

## Requirements

- **Hardware**
  - A CPU with virtualization support (Intel VT-x/AMD-V)
  - Motherboard and CPU support for IOMMU (Intel VT-d/AMD-Vi)
  - A dedicated GPU for the VM
  - Separate GPU for the host (optional but recommended)
- **Software**
  - Linux operating system with a recent kernel
  - QEMU/KVM or other virtualization software
  - Necessary drivers and firmware updates

## Getting Started

To begin setting up GPU passthrough:

### 1. **Check Hardware Compatibility**
   - **Virtualization Support**: Verify that your CPU supports virtualization (Intel VT-x/AMD-V). You can check this by running:
     ```bash
     egrep -o '(vmx|svm)' /proc/cpuinfo
     ```
     If the output includes `vmx` (for Intel) or `svm` (for AMD), your CPU supports virtualization.
   - **IOMMU Support**: Your motherboard and CPU must support IOMMU (Intel VT-d/AMD-Vi). To verify, run the following command:
     ```bash
     dmesg | grep -e DMAR -e IOMMU
     ```
     If IOMMU is supported, you should see relevant messages in the output.

### 2. **Enable Virtualization in BIOS/UEFI**
   - Reboot your system and enter BIOS/UEFI by pressing a designated key (usually `Delete`, `F2`, or `Esc`).
   - Locate the virtualization settings. This could be under a tab like `Advanced` or `CPU Configuration`.
   - Enable **Intel VT-x** or **AMD-V**, and also **Intel VT-d** or **AMD-Vi** for IOMMU.
   - Save the settings and reboot into your operating system.

### Enable IOMMU in Bootloader

To enable IOMMU, you first need to identify which bootloader your system uses. Common bootloaders include GRUB and systemd-boot. Follow the steps below to determine your bootloader and configure IOMMU accordingly.

#### Determine Your Bootloader
   - **Check GRUB**:
     ```bash
     sudo test -e /boot/grub/grub.cfg && echo "GRUB detected"
     ```
   - **Check systemd-boot**:
     ```bash
     sudo test -e /boot/loader/loader.conf && echo "systemd-boot detected"
     ```

#### Enable IOMMU in GRUB

1. **Edit the GRUB Configuration**:
   - Open the GRUB configuration file for editing:
     ```bash
     sudo nano /etc/default/grub
     ```
   - Add the appropriate IOMMU settings to the `GRUB_CMDLINE_LINUX_DEFAULT` line:
     - For **Intel** CPUs:
       ```bash
       GRUB_CMDLINE_LINUX_DEFAULT="quiet splash .... intel_iommu=on"
       ```
     - For **AMD** CPUs:
       ```bash
       GRUB_CMDLINE_LINUX_DEFAULT="quiet splash .... amd_iommu=on"
       ```

2. **Update GRUB**:
   - Save the changes and update GRUB:
     - On Ubuntu/Debian-based Distributions:
       ```bash
       sudo update-grub
       ```
     - On Arch Linux:
       ```bash
       sudo grub-mkconfig -o /boot/grub/grub.cfg
       ```
     - On Fedora:
       ```bash
       sudo grub2-mkconfig -o /boot/grub2/grub.cfg
       ```

3. **Reboot Your System**:
   - Apply the changes by rebooting:
     ```bash
     sudo reboot
     ```

4. **Verify IOMMU Activation**:
   - After rebooting, check if IOMMU is enabled:
     ```bash
     dmesg | grep -e DMAR -e IOMMU
     ```

#### Enable IOMMU in systemd-boot

1. **Edit the systemd-boot Configuration**:
   - Open the boot loader configuration file:
     ```bash
     sudo nano /boot/loader/entries/your-entry.conf (your-entry.conf has other name in each distro)
     ```
   - Add the IOMMU settings to the `options` line:
     - For **Intel** CPUs:
       ```bash
       options intel_iommu=on
       ```
     - For **AMD** CPUs:
       ```bash
       options amd_iommu=on
       ```

2. **Reboot Your System**:
   - Apply the changes by rebooting:
     ```bash
     sudo reboot
     ```

3. **Verify IOMMU Activation**:
   - After rebooting, check if IOMMU is enabled:
     ```bash
     lsmod | grep kvm
     ```


### 3. **Configure the Host System**

#### Install Necessary Packages
- **For Ubuntu/Debian**:
   ```bash
   sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system virt-manager ovmf
- **For Arch Linux:**:
   ```bash
  sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs
- **For Fedora:**:
   ```bash
   sudo dnf install qemu-kvm libvirt virt-manager virt-install ovmf
  ```
   
#### Setting Up the Virtual Machine

- **Enable and Start libvirt Services**:
```bash
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```
- **Verify that Your User Is in the libvirt Group Ensure your user is in the libvirt group to have the necessary permissions to manage VMs:**:
```bash
sudo usermod -aG libvirt $(whoami)
newgrp libvirt
```
### Setting Up the Virtual Machine Using Virt-Manager

1. **Open Virt-Manager**
   - Launch **Virt-Manager** from your application menu or by searching for it.

2. **Create a New Virtual Machine**
   - Click the **“Create a new virtual machine”** button.

3. **Choose Installation Media**
   - Select **“Local install media (ISO image or CDROM)”** if you have an ISO file.
   - Click **“Forward”**.
   - Browse to and select your ISO file, then click **“Forward”**. (if it doesn't go forward **unselect** the Automatically detect from the installation media/source and write it on your own)

4. **Allocate Resources**
   - **Memory**: Allocate RAM (e.g., 8 GB).
   - **CPUs**: Allocate CPU cores (e.g., 4 cores).
   - Click **“Forward”**.

5. **Configure Storage**
   - **Create a new virtual disk**: Set the disk size (e.g., 40 GB) and format (e.g., QCOW2).
   - Click **“Forward”**.

6. **Give Name**
  - **Name your VM**
  - **Check the box "Customize configuration before install"**

7. **Set Up Networking**
   - Choose the network configuration:
     - **Default**: Use NAT to share the host’s IP address.
     - **Bridged**: If you need a separate IP address for the VM.
   - Click **“Forward”**.

8. **Customize Configuration**
   - Check **“Customize configuration before install”** to adjust additional settings.
   - Click **“Finish”** to open the configuration window.
   - In the configuration window, go to the **Firmware** section and select **UEFI (OVMF)** if you are installing an OS that supports UEFI.

9. **Add Virtio**
    Download Virtio ISO from here **https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md**
    - Click **Add Hardware**.
    - Click **Storage**.
    - Click **Select or create custom storage**.
    - Click **Manage** and then select Virtio ISO file.
    - Select in Device Type **CDROM device** and in BUS Type **SATA**.
    - Click **Finish**.

11. **Begin Installation**
    - Click **“Begin Installation”** to start the virtual machine and follow the installation prompts to set up your operating system.

By following these steps, you'll have your virtual machine set up and ready for use with Virt-Manager.

12. **Install Virtio**

    ![Screenshot from 2024-09-07 13-21-33](https://github.com/user-attachments/assets/8d380e73-878b-4b3d-a601-9a4609346aff)

    - Select this Disk and then execute and install this file.

    ![Screenshot from 2024-09-07 13-23-56](https://github.com/user-attachments/assets/bd481f9c-6d0a-44ff-9b72-628e7a1f859b)

    - Shut Down the System.
      
13. **Enable XML**
    - Go to **Edit**.
    - Click **Preferences**.
    - Click **Enable XML editting**.

14. **Change the XML For SATA**
    - Change **bus="sata"** to **bus="virtio"**.
    - Change **type="drive"** to **type="pci"**.
      
![Screenshot from 2024-09-07 13-31-49](https://github.com/user-attachments/assets/3107a02a-c9c8-472f-abcb-26596c231bd8)


15. **Set VNC**
    - Go to **Display Spice**.
    - Change Type to **VNC server**.
    - Change Address to **All interfaces**
   
    ![Screenshot from 2024-09-07 13-38-43](https://github.com/user-attachments/assets/24d333cf-5e6a-4eae-a72e-d90476301d91)


17. **Setting Up Libvirt hooks**
    - Create /etc/libvirt/hooks
      ```bash
      sudo mkdir -p /etc/libvirt/hooks
      ```
    - Run the following command to install the hook manager and make it executable
      ```bash
      sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' \ -O /etc/libvirt/hooks/qemu
      sudo chmod +x /etc/libvirt/hooks/qemu
      ```
    - Restarting the libvirtd
      ```bash
      sudo service libvirtd restart
                OR
      sudo systemctl restart libvirtd
      ```
      - Making the start script
        ```bash
        sudo mkdir -p /etc/libvirt/hooks/qemu.d/{VM Name}/prepare/begin 
        ```
        
        ```bash
        cd /etc/libvirt/hooks/qemu.d/{VM Name}/prepare/begin
        ```

        ```bash
        sudo nano start.sh
        ```

      ## Start Script ##

      ```bash
      #!/bin/bash
      # Helpful to read output when debugging 
      set -x

      # Stop display manager
      systemctl stop display-manager.service
      ## Uncomment the following line if you use GDM
      killall gdm-x-session
      sudo rmmod nvidia_drm
      sudo rmmod nvidia_uvm
      sudo rmmod nvidia_modeset
      sudo rmmod nvidia

      # Unbind VTconsoles
      echo 0 > /sys/class/vtconsole/vtcon0/bind
      echo 0 > /sys/class/vtconsole/vtcon1/bind

      # Unbind EFI-Framebuffer
      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

      # Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
      sleep 2

      # Unbind the GPU from display driver 
      virsh nodedev-detach pci_0000_01_00_0  
      virsh nodedev-detach pci_0000_01_00_1

      # Load VFIO Kernel Module
      modprobe vfio-pci
      ```

      **Save and make it Executable**
      ```bash
      sudo chmod +x /etc/libvirt/hooks/qemu.d/{VMName}/prepare/begin/start.sh
      ```

      - Making the start script
       ```bash
      sudo mkdir -p /etc/libvirt/hooks/qemu.d/{VMName}/release/end/revert.sh
       ```

       ```bash
       cd /etc/libvirt/hooks/qemu.d/{VMName}/release/end/revert.sh
       ```

       ```bash
       sudo nano revert.sh
       ```

      ## End Script ##

      ```bash
      #!/bin/bash
      echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
      set -x

      # Re-Bind GPU to Nvidia Driver
      virsh nodedev-reattach pci_0000_01_00_0
      virsh nodedev-reattach pci_0000_01_00_1

      sleep 2

      # Reload nvidia modules
      modprobe -r vfio-pci
      modprobe -r nvidia
      modprobe -r nvidia_modeset
      modprobe -r nvidia_uvm
      modprobe -r nvidia_drm

      # Rebind VT consoles
      echo 1 > /sys/class/vtconsole/vtcon0/bind
      # Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
      #echo 1 > /sys/class/vtconsole/vtcon1/bind

      nvidia-xconfig --query-gpu-info > /dev/null 2>&1
      echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

      # Restart Display Manager
      systemctl start display-manager.service
      ```

**Customize the filess**
- Change the marked numbers with yours
![Screenshot from 2024-09-07 14-25-11](https://github.com/user-attachments/assets/fec73398-66f0-4bdf-b426-07d69b311375)

- To find those numbers for your specific system type this command
  ```bash
  lspci
  ```
- In my case those are the numbers (You probaly have different numbers or even more that two PCI's)
  
      
![Screenshot from 2024-09-07 14-30-04](https://github.com/user-attachments/assets/2bb46be2-23eb-4229-a65d-873e5e37aa9b)


- The same goes for the modules. If you have amd or intel find those modules for your system and replace them.

![Screenshot from 2024-09-07 14-34-03](https://github.com/user-attachments/assets/0852a2ad-6d45-4fc3-a631-613780cd8fc9)

**Add the Graphics Card to the VM**
- Click on Add Hardware and select your **Graphics Card**

![Screenshot from 2024-09-07 14-41-43](https://github.com/user-attachments/assets/460c694d-7604-4fdc-9da7-d8f72b4f2b79)

**Single GPU Passthrough**

- When start your VM you will not have any output because your graphics card will be connected to the VM.
- If you have windows in your VM you can just wait until they drivers will be automatically downloaded or you can connect from an other device to your VM with VNC.
