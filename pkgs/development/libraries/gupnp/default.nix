{ stdenv, fetchurl, pkgconfig, glib, gssdp, libsoup, libxml2, libuuid }:
 
stdenv.mkDerivation rec {
  name = "gupnp-${version}";
  majorVersion = "0.20";
  version = "${majorVersion}.14";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${majorVersion}/gupnp-${version}.tar.xz";
    sha256 = "77ffb940ba77c4a6426d09d41004c75d92652dcbde86c84ac1c847dbd9ad59bd";
  };

  outputs = [ "dev" "out" "docdev" ];
  outputBin = "dev";

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ glib gssdp libsoup libxml2 libuuid ];

  postInstall = ''
    ln -sv ${libsoup}/include/*/libsoup $dev/include
    ln -sv ${libxml2.dev}/include/*/libxml $dev/include
    ln -sv ${gssdp}/include/*/libgssdp $dev/include
  '';

  meta = {
    homepage = http://www.gupnp.org/;
    description = "An implementation of the UPnP specification";
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
  };
}
