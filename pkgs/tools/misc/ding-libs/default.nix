{ stdenv, fetchurl, check }:

stdenv.mkDerivation rec {
  name = "ding-libs-${version}";
  version = "0.6.0";

  src = fetchurl {
    url = "https://fedorahosted.org/released/ding-libs/${name}.tar.gz";
    sha256 = "1bczkvq7cblp75kqn6r2d7j5x7brfw6wxirzc6d2rkyb80gj2jkn";
  };

  enableParallelBuilding = true;
  buildInputs = [ check ];

  doCheck = true;

  meta = {
    description = "'D is not GLib' utility libraries";
    homepage = https://fedorahosted.org/sssd/;
    maintainers = with stdenv.lib.maintainers; [ benwbooth ];
    license = [ stdenv.lib.licenses.gpl3 stdenv.lib.licenses.lgpl3 ];
  };
}
