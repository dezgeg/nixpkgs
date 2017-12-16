{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.packetImage;
in {

  imports = [ ../../../modules/virtualisation/packet-t2a.nix ];

  options.packetImage = {
    name = mkOption {
      type = types.str;
      description = "The name of the generated derivation";
      default = "nixos-disk-image";
    };

    contents = mkOption {
      example = literalExample ''
        [ { source = pkgs.memtest86 + "/memtest.bin";
            target = "boot/memtest.bin";
          }
        ]
      '';
      default = [];
      description = ''
        This option lists files to be copied to fixed locations in the
        generated image. Glob patterns work.
      '';
    };

    sizeMB = mkOption {
      type = types.int;
      default = 2500;
      description = "The size in MB of the image";
    };

    format = mkOption {
      type = types.enum [ "raw" "qcow2" "vpc" ];
      default = "qcow2";
      description = "The image format to output";
    };
  };

  config.system.build.packetImage = import ../../../lib/make-disk-image.nix {
    inherit lib config;
    inherit (cfg) contents format name;
    pkgs = import ../../../.. { inherit (pkgs) system; }; # ensure we use the regular qemu-kvm package
    partitionTableType = "efi";
    diskSize = cfg.sizeMB;
    configFile = pkgs.writeText "configuration.nix"
      ''
        {
          imports = [ <nixpkgs/nixos/modules/virtualisation/packet-t2a.nix> ];
        }
      '';
  };
}
