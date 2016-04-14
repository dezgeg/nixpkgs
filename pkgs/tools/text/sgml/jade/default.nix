{ stdenv, fetchurl, gnum4 }:

stdenv.mkDerivation rec {
  name = "jade-${version}";
  version = "1.2.1";
  debpatch = "47.3";

  src = fetchurl {
    url = "ftp://ftp.jclark.com/pub/jade/${name}.tar.gz";
    sha256 = "11xifjk4dixn7al06gn7whcv46grsh2i9ds6dbw49avsm2igiql4";
  };

  patchsrc =  fetchurl {
    url = "http://ftp.debian.org/debian/pool/main/j/jade/jade_${version}-${debpatch}.diff.gz";
    sha256 = "0r2l614dwhx718km2hcr45prljavp9jnm1azh0436l73k1l4i54f";
  };

  enableParallelBuilding = false;
  buildInputs = [ gnum4 ];

  patchPhase = ''
    gzip -cd "$patchsrc" | patch -p1
  '';

  preInstall = ''
    mkdir -p $out/lib
  '';

  postInstall = ''
    ln -s sx $out/bin/sgml2xml
  '';

  meta = {
    description = "James Clark's DSSSL Engine";
    license = "custom";
    homepage = http://www.jclark.com/jade/;
    maintainers = with stdenv.lib.maintainers; [ benwbooth ];
  };
}
