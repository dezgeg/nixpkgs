{ fetchurl, stdenv, gettext, glibc }:

stdenv.mkDerivation (rec {
  name = "libelf-0.8.13";

  src = fetchurl {
    url = "http://www.mr511.de/software/${name}.tar.gz";
    sha256 = "0vf7s9dwk2xkmhb79aigqm0x0yfbw1j0b9ksm51207qwr179n6jr";
  };

  postPatch = if stdenv.isAarch64 then ''
    cp ${../../../../config.guess} config.guess
    cp ${../../../../config.sub} config.sub
  '' else null;

  doCheck = true;

  # For cross-compiling, native glibc is needed for the "gencat" program.
  crossAttrs = {
    nativeBuildInputs = [ glibc gettext ];
  };

  buildInputs = if stdenv ? cross then [ ] else [ gettext ];

  meta = {
    description = "ELF object file access library";

    homepage = http://www.mr511.de/software/english.html;

    license = stdenv.lib.licenses.lgpl2Plus;

    platforms = stdenv.lib.platforms.all;
    maintainers = [ ];
  };
}

//

# Libelf's custom NLS macros fail to determine the catalog file extension on
# Darwin, so disable NLS for now.
# FIXME: Eventually make Gettext a build input on all platforms.
(if stdenv.isDarwin
 then { configureFlags = [ "--disable-nls" ]; }
 else { }))
