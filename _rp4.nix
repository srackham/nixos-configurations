# Raspberry Pi 4 specific options.
{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = ["noatime"];
  };
  fileSystems."/files" = {
    # Samsung 2TB USB drive, partition 1 containing NAS data.
    device = "/dev/disk/by-uuid/10fcd726-ccff-4cb6-8b34-21b3d7c554ce";
    fsType = "ext4";
    options = ["noatime"];
  };
}
