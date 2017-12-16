{ config, lib, pkgs, ... }:

{
  config = {
    boot.growPartition = true;

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
    };

    boot.kernelParams = [ "console=ttyAMA0" ];

    boot.loader.grub.version = 2;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.timeout = 5;

    # Allow root logins only using the SSH key that the user specified
    # at instance creation time.
    services.openssh.enable = true;
    services.openssh.permitRootLogin = "prohibit-password";
  };
}
