{
  busybox = import <nix/fetchurl.nix> {
    url = http://nixos-arm.dezgeg.me/bootstrap-2016-08-28-1409bc/armv5tel/busybox;
    sha256 = "1bn4higchnrlqxjg1ivkhlin4xr9zdychgx332h2cfq9zxginanv";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = http://nixos-arm.dezgeg.me/bootstrap-2016-08-28-1409bc/armv5tel/bootstrap-tools.tar.xz;
    sha256 = "145jrqyxl75iv5i1f7d5h01y2hj3pbc3gvxyjng9hdyks71jz81i";
  };
}
