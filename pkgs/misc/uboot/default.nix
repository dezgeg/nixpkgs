{ stdenv, fetchurl, fetchpatch, bc, dtc, openssl, python2, swig
, hostPlatform, buildPackages
}:

let
  buildUBoot = { filesToInstall
            , installDir ? "$out"
            , defconfig
            , extraMakeFlags ? []
            , extraMeta ? {}
            , ... } @ args:
           stdenv.mkDerivation (rec {

    name = "uboot-${defconfig}-${version}";
    version = "2018.01";

    src = fetchurl {
      url = "ftp://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
      sha256 = "1nidnnjprgxdhiiz7gmaj8cgcf52l5gbv64cmzjq4gmkjirmk3wk";
    };

    patches = [
      (fetchpatch {
        url = https://github.com/dezgeg/u-boot/commit/cbsize-2017-11.patch;
        sha256 = "08rqsrj78aif8vaxlpwiwwv1jwf0diihbj0h88hc0mlp0kmyqxwm";
      })
      (fetchpatch {
        url = https://github.com/dezgeg/u-boot/commit/rpi-2017-11-patch1.patch;
        sha256 = "067yq55vv1slv4xy346px7h329pi14abdn04chg6s1s6hmf6c1x9";
      })
      (fetchpatch {
        url = https://github.com/dezgeg/u-boot/commit/rpi-2017-11-patch2.patch;
        sha256 = "0bbw0q027xvzvdxxvpzjajg4rm30a8mb7z74b6ma9q0l7y7bi0c4";
      })
      (fetchpatch {
        url = https://github.com/dezgeg/u-boot/commit/pythonpath-2018-03.patch;
        sha256 = "0bhbnxhpf7x6kk5ikhy6hzf5k132mc0pvin90hn8dbw028d6cyma";
      })
    ];

    postPatch = ''
      patchShebangs tools
    '';

    nativeBuildInputs = [ bc dtc openssl python2 swig ];
    depsBuildBuild = [ buildPackages.stdenv.cc ];

    hardeningDisable = [ "all" ];

    makeFlags = [
      "DTC=dtc"
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    ] ++ extraMakeFlags;

    configurePhase = ''
      make ${defconfig}
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p ${installDir}
      cp ${stdenv.lib.concatStringsSep " " filesToInstall} ${installDir}

      runHook postInstall
    '';

    enableParallelBuilding = true;
    dontStrip = true;

    meta = with stdenv.lib; {
      homepage = http://www.denx.de/wiki/U-Boot/;
      description = "Boot loader for embedded systems";
      license = licenses.gpl2;
      maintainers = [ maintainers.dezgeg ];
    } // extraMeta;
  } // removeAttrs args [ "extraMeta" ]);

in rec {
  inherit buildUBoot;

  ubootTools = buildUBoot rec {
    defconfig = "allnoconfig";
    installDir = "$out/bin";
    buildFlags = "tools NO_SDL=1";
    hardeningDisable = [];
    dontStrip = false;
    extraMeta.platforms = stdenv.lib.platforms.linux;
    # build tools/kwboot
    extraMakeFlags = [ "CONFIG_KIRKWOOD=y" ];
    filesToInstall = [
      "tools/dumpimage"
      "tools/fdtgrep"
      "tools/kwboot"
      "tools/mkenvimage"
      "tools/mkimage"
    ];
  };

  ubootA20OlinuxinoLime = buildUBoot rec {
    defconfig = "A20-OLinuXino-Lime_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  };

  ubootBananaPi = buildUBoot rec {
    defconfig = "Bananapi_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  };

  ubootBeagleboneBlack = buildUBoot rec {
    defconfig = "am335x_boneblack_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["MLO" "u-boot.img"];
  };

  # http://git.denx.de/?p=u-boot.git;a=blob;f=board/solidrun/clearfog/README;hb=refs/heads/master
  ubootClearfog = buildUBoot rec {
    defconfig = "clearfog_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-spl.kwb"];
  };

  ubootJetsonTK1 = buildUBoot rec {
    defconfig = "jetson-tk1_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot" "u-boot.dtb" "u-boot-dtb-tegra.bin" "u-boot-nodtb-tegra.bin"];
  };

  ubootOdroidXU3 = buildUBoot rec {
    defconfig = "odroid-xu3_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-dtb.bin"];
  };

  ubootOrangePiPc = buildUBoot rec {
    defconfig = "orangepi_pc_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  };

  ubootPcduino3Nano = buildUBoot rec {
    defconfig = "Linksprite_pcDuino3_Nano_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  };

  ubootQemuArm = buildUBoot rec {
    defconfig = "qemu_arm_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootRaspberryPi = buildUBoot rec {
    defconfig = "rpi_defconfig";
    extraMeta.platforms = ["armv6l-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootRaspberryPi2 = buildUBoot rec {
    defconfig = "rpi_2_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootRaspberryPi3_32bit = buildUBoot rec {
    defconfig = "rpi_3_32b_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootRaspberryPi3_64bit = buildUBoot rec {
    defconfig = "rpi_3_defconfig";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootUtilite = buildUBoot rec {
    defconfig = "cm_fx6_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-with-nand-spl.imx"];
    buildFlags = "u-boot-with-nand-spl.imx";
    postConfigure = ''
      cat >> .config << EOF
      CONFIG_CMD_SETEXPR=y
      EOF
    '';
    # sata init; load sata 0 $loadaddr u-boot-with-nand-spl.imx
    # sf probe; sf update $loadaddr 0 80000
  };

  ubootWandboard = buildUBoot rec {
    defconfig = "wandboard_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.img" "SPL"];
  };
}
