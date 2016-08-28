{
  busybox = import <nix/fetchurl.nix> {
    url = http://nixos-arm.dezgeg.me/bootstrap-2016-08-28-1409bc/armv7l/busybox;
    sha256 = "0kb439p37rzlascp6ldm4kwf5kwd6p3lv17c41zwj20wbv8sdilq";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = http://nixos-arm.dezgeg.me/bootstrap-2016-08-28-1409bc/armv7l/bootstrap-tools.tar.xz;
    sha256 = "14693slz9zf0fq0xghs76b3ffjqqxyx790qgb7gqq95s1svrbqg4";
  };
}
