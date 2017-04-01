{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "wireless-tools-${version}";
  version = "29";

  src = fetchurl {
    url = "https://hewlettpackard.github.io/wireless-tools/wireless_tools.${version}.tar.gz";
    sha256 = "18g5wa3rih89i776nc2n2s50gcds4611gi723h9ki190zqshkf3g";
  };

  preBuild = ''
    makeFlagsArray=(PREFIX=$out)
  '';

  meta = {
    homepage = https://hewlettpackard.github.io/wireless-tools/Tools.html;
    downloadPage = https://hewlettpackard.github.io/wireless-tools/Tools.html;
    platforms = stdenv.lib.platforms.linux;
  };
}
