{
  busybox = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/aarch64/fd81a2ecb6b85594dc79ad53566c822849d4e47a/busybox;
    sha256 = "15xc6hpxgy0j8rgpf5v7m40r2i4d623c9bi9007i37yrmlg924d7";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/aarch64/fd81a2ecb6b85594dc79ad53566c822849d4e47a/bootstrap-tools.tar.xz;
    sha256 = "19hdkq0a9q26855s0dbhwflfly9bx7kzh359w0p1j8bjxhffziqq";
  };
}
