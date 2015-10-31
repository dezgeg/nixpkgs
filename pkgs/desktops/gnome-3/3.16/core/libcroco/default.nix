{ stdenv, fetchurl, pkgconfig, libxml2, glib }:

stdenv.mkDerivation rec {
  name = "libcroco-0.6.8";

  src = fetchurl {
    url = "mirror://gnome/sources/libcroco/0.6/${name}.tar.xz";
    sha256 = "0w453f3nnkbkrly7spx5lx5pf6mwynzmd5qhszprq8amij2invpa";
  };

  outputs = [ "dev" "out" "docdev" ];

  buildInputs = [ pkgconfig libxml2 glib ];

  configureFlags = stdenv.lib.optional stdenv.isDarwin "--disable-Bsymbolic";

  postInstall = ''
    mkdir -p $dev/bin
    mv $out/bin/croco-0.6-config $dev/bin/
  '';

  meta = with stdenv.lib; {
    platforms = platforms.unix;
  };
}
