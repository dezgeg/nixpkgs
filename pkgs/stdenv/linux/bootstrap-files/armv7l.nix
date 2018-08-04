{
  busybox = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/armv7l/fd81a2ecb6b85594dc79ad53566c822849d4e47a/busybox;
    sha256 = "1y16xgm9vfn8w6jbh0qif5lyv6rjynm22khc3nxqa1w6m14jiz08";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/armv7l/fd81a2ecb6b85594dc79ad53566c822849d4e47a/bootstrap-tools.tar.xz;
    sha256 = "0yzw4jfgbf8xn9s34in0wza534xk4yvpx8cpsl6x1f3gss0cyw93";
  };
}
