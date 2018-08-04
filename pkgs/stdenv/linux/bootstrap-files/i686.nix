{
  busybox = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/i686/fd81a2ecb6b85594dc79ad53566c822849d4e47a/busybox;
    sha256 = "0jygn15rdqx1nv3za0i5znvjbrxb4by8ksxndxf1inwyly1wli3w";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/i686/fd81a2ecb6b85594dc79ad53566c822849d4e47a/bootstrap-tools.tar.xz;
    sha256 = "0hwi9rapphrhnbamgj6ywbqm81pp0zc2g0lyimj4bnqnfkxbl4kz";
  };
}
