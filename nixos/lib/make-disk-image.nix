{ pkgs
, lib

, # The NixOS configuration to be installed onto the disk image.
  config

, # The size of the disk, in megabytes.
  diskSize

  # The files and directories to be placed in the target file system.
  # This is a list of attribute sets {source, target} where `source'
  # is the file system object (regular file or directory) to be
  # grafted in the file system at path `target'.
, contents ? []

, # Whether the disk should be partitioned (with a single partition
  # containing the root filesystem) or contain the root filesystem
  # directly.
  partitioned ? true

, # Either "legacy" or "efi". For "legacy" images, a msdos partition
  # table is created (if `partitioned` is true) and GRUB will be
  # installed in legacy mode (if `installBootLoader` is true).
  # For "efi" images, GPT partition table is used and an ESP partition
  # is created (so `partitioned` MUST be true) and GRUB will be
  # installed in EFI mode (if `installBootLoader` is true).
  imageType ? "legacy"

  # Whether to invoke switch-to-configuration boot during image creation
, installBootLoader ? true

, # The root file system type.
  fsType ? "ext4"

, # The initial NixOS configuration file to be copied to
  # /etc/nixos/configuration.nix.
  configFile ? null

, # Shell code executed after the VM has finished.
  postVM ? ""

, name ? "nixos-disk-image"

, # Disk image format, one of qcow2, qcow2-compressed, vpc, raw.
  format ? "raw"
}:

assert imageType == "legacy" || imageType == "efi";
# EFI images always need an ESP
assert imageType == "efi" -> partitioned;
# We use -E offset=X below, which is only supported by e2fsprogs
assert partitioned -> fsType == "ext4";

with lib;

let format' = format; in let

  format = if (format' == "qcow2-compressed") then "qcow2" else format';

  compress = optionalString (format' == "qcow2-compressed") "-c";

  filename = "nixos." + {
    qcow2 = "qcow2";
    vpc   = "vhd";
    raw   = "img";
  }.${format};

  rootPartition = assert partitioned; if imageType == "legacy" then "1" else "2";

  nixpkgs = cleanSource pkgs.path;

  channelSources = pkgs.runCommand "nixos-${config.system.nixosVersion}" {} ''
    mkdir -p $out
    cp -prd ${nixpkgs} $out/nixos
    chmod -R u+w $out/nixos
    if [ ! -e $out/nixos/nixpkgs ]; then
      ln -s . $out/nixos/nixpkgs
    fi
    rm -rf $out/nixos/.git
    echo -n ${config.system.nixosVersionSuffix} > $out/nixos/.version-suffix
  '';

  metaClosure = pkgs.writeText "meta" ''
    ${config.system.build.toplevel}
    ${config.nix.package.out}
    ${channelSources}
  '';

  prepareImageInputs = with pkgs; [ rsync utillinux parted e2fsprogs lkl fakeroot config.system.build.nixos-prepare-root ] ++ stdenv.initialPath;

  # I'm preserving the line below because I'm going to search for it across nixpkgs to consolidate
  # image building logic. The comment right below this now appears in 4 different places in nixpkgs :)
  # !!! should use XML.
  sources = map (x: x.source) contents;
  targets = map (x: x.target) contents;

  prepareImage = ''
    export PATH=${makeSearchPathOutput "bin" "bin" prepareImageInputs}

    # Yes, mkfs.ext4 takes different units in different contexts. Fun.
    sectorsToKilobytes() {
      echo $(( ( "$1" * 512 ) / 1024 ))
    }

    sectorsToBytes() {
      echo $(( "$1" * 512  ))
    }

    mkdir $out
    diskImage=nixos.raw
    truncate -s ${toString diskSize}M $diskImage

    ${optionalString partitioned (
      if imageType == "legacy" then ''
          parted --script $diskImage -- \
            mklabel msdos \
            mkpart primary ext4 1MiB -1
        '' else ''
          parted --script $diskImage -- \
            mklabel gpt \
            mkpart ESP fat32 8MiB 256MiB \
            set 1 boot on \
            mkpart primary ext4 256MiB -1
        ''
    )}

    ${if partitioned then ''
      # Get start & length of the root partition in sectors to $START and $SECTORS.
      eval $(partx $diskImage -o START,SECTORS --nr ${rootPartition} --pairs)

      mkfs.${fsType} -F -L nixos $diskImage -E offset=$(sectorsToBytes $START) $(sectorsToKilobytes $SECTORS)K
    '' else ''
      mkfs.${fsType} -F -L nixos $diskImage
    ''}

    root="$PWD/root"
    mkdir -p $root

    # Copy arbitrary other files into the image
    # Semi-shamelessly copied from make-etc.sh. I (@copumpkin) shall factor this stuff out as part of
    # https://github.com/NixOS/nixpkgs/issues/23052.
    set -f
    sources_=(${concatStringsSep " " sources})
    targets_=(${concatStringsSep " " targets})
    set +f

    for ((i = 0; i < ''${#targets_[@]}; i++)); do
      source="''${sources_[$i]}"
      target="''${targets_[$i]}"

      if [[ "$source" =~ '*' ]]; then
        # If the source name contains '*', perform globbing.
        mkdir -p $root/$target
        for fn in $source; do
          rsync -a --no-o --no-g "$fn" $root/$target/
        done
      else
        mkdir -p $root/$(dirname $target)
        if ! [ -e $root/$target ]; then
          rsync -a --no-o --no-g $source $root/$target
        else
          echo "duplicate entry $target -> $source"
          exit 1
        fi
      fi
    done

    # TODO: Nix really likes to chown things it creates to its current user...
    fakeroot nixos-prepare-root $root ${channelSources} ${config.system.build.toplevel} closure

    echo "copying staging root to image..."
    cptofs -p ${optionalString partitioned "-P ${rootPartition}"} -t ${fsType} -i $diskImage $root/* /
  '';
in pkgs.vmTools.runInLinuxVM (
  pkgs.runCommand name
    { preVM = prepareImage;
      buildInputs = with pkgs; [ utillinux e2fsprogs dosfstools ];
      exportReferencesGraph = [ "closure" metaClosure ];
      postVM = ''
        ${if format == "raw" then ''
          mv $diskImage $out/${filename}
        '' else ''
          ${pkgs.qemu}/bin/qemu-img convert -f raw -O ${format} ${compress} $diskImage $out/${filename}
        ''}
        diskImage=$out/${filename}
        ${postVM}
      '';
      memSize = 1024;
    }
    ''
      rootDisk=${if partitioned then "/dev/vda${rootPartition}" else "/dev/vda"}

      # Some tools assume these exist
      ln -s vda /dev/xvda
      ln -s vda /dev/sda

      mountPoint=/mnt
      mkdir $mountPoint
      mount $rootDisk $mountPoint

      # Create the ESP and mount it. Unlike e2fsprogs, mkfs.vfat doesn't support an
      # '-E offset=X' option, so we can't do this outside the VM.
      ${optionalString (imageType == "efi") ''
        mkdir -p /mnt/boot
        mkfs.vfat -n ESP /dev/vda1
        mount /dev/vda1 /mnt/boot
      ''}

      # Install a configuration.nix
      mkdir -p /mnt/etc/nixos
      ${optionalString (configFile != null) ''
        cp ${configFile} /mnt/etc/nixos/configuration.nix
      ''}

      mount --rbind /dev  $mountPoint/dev
      mount --rbind /proc $mountPoint/proc
      mount --rbind /sys  $mountPoint/sys

      # Set up core system link, GRUB, etc.
      NIXOS_INSTALL_BOOTLOADER=1 chroot $mountPoint /nix/var/nix/profiles/system/bin/switch-to-configuration boot

      # TODO: figure out if I should activate, but for now I won't
      # chroot $mountPoint /nix/var/nix/profiles/system/activate

      # The above scripts will generate a random machine-id and we don't want to bake a single ID into all our images
      rm -f $mountPoint/etc/machine-id

      umount -R /mnt

      # Make sure resize2fs works. Note that resize2fs has stricter criteria for resizing than a normal
      # mount, so the `-c 0` and `-i 0` don't affect it. Setting it to `now` doesn't produce deterministic
      # output, of course, but we can fix that when/if we start making images deterministic.
      ${optionalString (fsType == "ext4") ''
        tune2fs -T now -c 0 -i 0 $rootDisk
      ''}
    ''
)
