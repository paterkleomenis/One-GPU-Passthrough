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

   - **GPU Compatibility**: Make sure you have two GPUs:
     1. One for your host (the system running the virtualization software).
     2. One for the guest (the system in the virtual machine).
     You can also use an integrated GPU for the host and a dedicated one for the guest.

### 2. **Enable Virtualization in BIOS/UEFI**
   - Reboot your system and enter BIOS/UEFI by pressing a designated key (usually `Delete`, `F2`, or `Esc`).
   - Locate the virtualization settings. This could be under a tab like `Advanced` or `CPU Configuration`.
   - Enable **Intel VT-x** or **AMD-V**, and also **Intel VT-d** or **AMD-Vi** for IOMMU.
   - Save the settings and reboot into your operating system.

### 3. **Configure the Host System**

#### Install Necessary Packages
- **For Ubuntu/Debian**:
   ```bash
   sudo apt update
   sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system virt-manager ovmf


For detailed instructions, please refer to the [Setup Guides](./guides/README.md).

## Contributing

Contributions are welcome! Please read the [contribution guidelines](./CONTRIBUTING.md) first.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Acknowledgments

- Thanks to the open-source community for invaluable resources.
- Special mentions to contributors and testers.
