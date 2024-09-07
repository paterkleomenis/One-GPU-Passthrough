# GPU Passthrough on Linux

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

1. **Check the Bootloader**:
   - For **GRUB**: Run the following command to check if GRUB is installed:
     ```bash
     dpkg -l | grep grub
     ```
   - For **systemd-boot**: Check if the systemd-boot loader is installed:
     ```bash
     ls /boot/loader/entries/
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
       GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on"
       ```
     - For **AMD** CPUs:
       ```bash
       GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_iommu=on"
       ```

2. **Update GRUB**:
   - Save the changes and update GRUB:
     - On Ubuntu/Debian:
       ```bash
       sudo update-grub
       ```
     - On Arch Linux:
       ```bash
       sudo grub-mkconfig -o /boot/grub/grub.cfg
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
     sudo nano /boot/loader/entries/your-entry.conf
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
     dmesg | grep -e DMAR -e IOMMU
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

6. **Set Up Networking**
   - Choose the network configuration:
     - **Default**: Use NAT to share the host’s IP address.
     - **Bridged**: If you need a separate IP address for the VM.
   - Click **“Forward”**.

7. **Customize Configuration (Optional)**
   - Check **“Customize configuration before install”** to adjust additional settings.
   - Click **“Finish”** to open the configuration window.

8. **Configure GPU Passthrough (Optional)**
   - In the configuration window, go to the **Firmware** section and select **UEFI (OVMF)** if you are installing an OS that supports UEFI.
   - Go to the **Add Hardware** section, select **PCI Host Device**, and choose your GPU from the list.
   - Apply the changes.

9. **Begin Installation**
    - Click **“Begin Installation”** to start the virtual machine and follow the installation prompts to set up your operating system.

By following these steps, you'll have your virtual machine set up and ready for use with Virt-Manager.



