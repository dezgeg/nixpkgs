{ stdenv, autoconf, automake, elfutils, libcapsule, libtool, libX11, mesa_drivers, pkgconfig }:

stdenv.mkDerivation rec {
  name = "libcapsule-libgl-proxy";

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ libcapsule elfutils ];

  LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath [ mesa_drivers.out libX11 ]; # Ugly...

  unpackPhase = ''
    ${libcapsule}/libexec/capsule-init-project libGL.so.1 /
    cd libGL-proxy
    cp ${libcapsule.src}/shim/libGL.* shim/
  '';

  preConfigure = ''
    cat preconfigure.log
  '';

  dontStrip = true;
  NIX_CFLAGS_COMPILE = "-g";
}
