{
  busybox = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/x86_64/fd81a2ecb6b85594dc79ad53566c822849d4e47a/busybox;
    sha256 = "17rbs7q9q8hhdbz7bwb97vzimbfmz6iy413i2gwzwlvvj62kn02k";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/x86_64/fd81a2ecb6b85594dc79ad53566c822849d4e47a/bootstrap-tools.tar.xz;
    sha256 = "0y9h4mixwa033rqb4al86pl6pbxgick5wmf27ppwyvgzw4srfslw";
  };
}
