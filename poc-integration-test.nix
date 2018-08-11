{ system ? builtins.currentSystem }:

with import nixos/lib/testing.nix { inherit system; };
with pkgs.lib;

let

  diskImages = {
    # Arch Linux, no official cloud images available though.
    # FIXME: need to get my cloud-init patch to be merged
    arch = pkgs.fetchurl {
      url = "https://linuximages.de/openstack/arch/arch-openstack-2018-02-21-15-12-image-bootstrap-0.9.2.1-41-g1ce2043.qcow2";
      sha256 = "16fd0yhmrg28nrwhsngfk32cixsczfaqixvjb3csc2bxgdibp3jv";
    };

    centos_7 = pkgs.fetchurl {
      url = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1802.qcow2";
      sha256 = "1frwb6yd6gikklvwlbl4ysaycvnradw3aj9yg7gfb978zka3qqck";
    };

    # Debian 9 "Stretch"
    debian_9 = pkgs.fetchurl {
      url = "https://cdimage.debian.org/cdimage/openstack/9.4.3-20180416/debian-9.4.3-20180416-openstack-amd64.qcow2";
      sha256 = "0b308l7ln1sdy8qxfbvxfvvm5wz2klyicynwa0x8z1isspcwjm30";
    };

    # Fedora 27
    fedora_27 = pkgs.fetchurl {
      url = "https://download.fedoraproject.org/pub/fedora/linux/releases/27/CloudImages/x86_64/images/Fedora-Cloud-Base-27-1.6.x86_64.qcow2";
      sha256 = "1jflrp652jlk9l0r5s9wnnqrf0ka1krci7wqyjnk5hf8p5clpy2s";
    };

    # openSUSE 42.3 "Leap"
    # FIXME: need to get my cloud-init patch to be merged
    opensuse_42 = pkgs.fetchurl {
      url = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_42.3/images/openSUSE-Leap-42.3-OpenStack.x86_64.qcow2";
      sha256 = "0din7q5ii4mh0rk3l8vqkjg6xm3n7zkzm06wpg61b5wg1k2j3fx2";
    };

    # Ubuntu 16.04 LTS "Xenial Xerus"

    # Ubuntu 17.10 "Artful Aardvark"
    ubuntu_17_10 = pkgs.fetchurl {
      url = "https://cloud-images.ubuntu.com/releases/artful/release-20180423/ubuntu-17.10-server-cloudimg-amd64.img";
      sha256 = "10a36szm2ykhfl1jyxkxb7vyjs585r6gwahw9zv962hyqa844ddm";
    };
  };

  userdataFile = pkgs.writeText "cloud-init.conf" ''
    #cloud-config
    bootcmd:
      - echo "Hello from cloud-init"
      - sleep 3
      - echo b > /proc/sysrq-trigger
  '';

  fooTest = diskImage: makeTest {
    name = "ubuntu-aardvark";
    nodes = { };
    testScript = ''
      # FIXME: copy-pasted from nixos/tests/ec2.nix
      my $imageDir = ($ENV{'TMPDIR'} // "/tmp") . "/vm-state-machine";
      mkdir $imageDir, 0700;
      my $tmpDisk = "$imageDir/machine.qcow2";
      system("qemu-img create -f qcow2 -o backing_file=${diskImage} $tmpDisk") == 0 or die;
      system("qemu-img resize $tmpDisk 10G") == 0 or die;

      # Put a cloud-init configuration on a disk image we pass in via the emulated CD-ROM.
      #system("${pkgs.cloud-utils}/bin/cloud-localds -m local $imageDir/userdata-disk.img ${userdataFile}");
      system("${pkgs.cloud-utils}/bin/cloud-localds -m local $imageDir/userdata-disk.img ${userdataFile}");

      my $machine = createMachine({ qemuFlags => "-net user -drive file=$tmpDisk,if=virtio -cdrom $imageDir/userdata-disk.img" });
      $machine->start;
      $machine->waitForFile("/asd/bar/foo");
    '';
  };
in fooTest diskImages.ubuntu_17_10
