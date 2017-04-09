{ stdenv, fetchFromGitHub
, libsysfs, gnutls, openssl
, libcap, opensp, docbook_sgml_dtd_31
, libidn, nettle
, SGMLSpm, libgcrypt }:

assert stdenv ? glibc;

stdenv.mkDerivation rec {
  name = "iputils-${version}";
  version = "20161105";

  src = fetchFromGitHub {
    owner = "iputils";
    repo = "iputils";
    rev = "s${version}";
    sha256 = "1a4vkgb74lizcva3k2vddyn3932idww6fkadd65cb82dmg4gqqn0";
  };

  prePatch = ''
    sed -e s/sgmlspl/sgmlspl.pl/ \
        -e s/nsgmls/onsgmls/ \
      -i doc/Makefile
  '';

  makeFlags = "USE_GNUTLS=no";

  buildInputs = [
    libsysfs opensp openssl libcap docbook_sgml_dtd_31 SGMLSpm libgcrypt libidn nettle
  ];

  buildFlags = "man all ninfod";

  installPhase =
    ''
      mkdir -p $out/bin
      cp -p ping tracepath clockdiff arping rdisc ninfod/ninfod $out/bin/

      mkdir -p $out/share/man/man8
      cp -p \
        doc/clockdiff.8 doc/arping.8 doc/ping.8 doc/rdisc.8 doc/tracepath.8 doc/ninfod.8 \
        $out/share/man/man8
    '';

  meta = {
    homepage = https://github.com/iputils/iputils;
    description = "A set of small useful utilities for Linux networking";
    platforms = stdenv.lib.platforms.linux;
  };
}
