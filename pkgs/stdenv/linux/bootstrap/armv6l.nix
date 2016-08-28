{
  busybox = import <nix/fetchurl.nix> {
    url = http://nixos-arm.dezgeg.me/bootstrap-2016-08-28-1409bc/armv6l/busybox;
    sha256 = "1vl1nx7ccalp2w8d5ymj6i2vs0s9w80xvxpsxl2l24k5ibbspcy0";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = http://nixos-arm.dezgeg.me/bootstrap-2016-08-28-1409bc/armv6l/bootstrap-tools.tar.xz;
    sha256 = "1s8ljv008lpq0wfqfs5n0gk0kl23xdwnkvadinagp5zyzpjfdw8x";
  };
}
