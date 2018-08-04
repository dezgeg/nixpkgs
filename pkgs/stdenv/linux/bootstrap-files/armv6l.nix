{
  busybox = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/armv6l/fd81a2ecb6b85594dc79ad53566c822849d4e47a/busybox;
    sha256 = "1n1r8c4f1mfscbxq13n72xj292hhpcr4d8gpfd7nfk8r87c9mlj4";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/armv6l/fd81a2ecb6b85594dc79ad53566c822849d4e47a/bootstrap-tools.tar.xz;
    sha256 = "06az5zp9cbjpg0d12f62bv5d8c2gqsb56m5mik7vl7hm5i53yq1f";
  };
}
