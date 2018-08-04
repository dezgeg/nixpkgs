{
  busybox = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/armv5tel/fd81a2ecb6b85594dc79ad53566c822849d4e47a/busybox;
    sha256 = "02rhgs1zxvkqqhfrx01spxlz4xhh4cbfakfn3n96w8ihxgzk4v01";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://cs.helsinki.fi/u/tmtynkky/tmp-bootstrap/stdenv-linux/armv5tel/fd81a2ecb6b85594dc79ad53566c822849d4e47a/bootstrap-tools.tar.xz;
    sha256 = "1nya00fnsimk8hicjq0i3n7aa19y7qgps2bh64qhcyn444nk9spw";
  };
}
