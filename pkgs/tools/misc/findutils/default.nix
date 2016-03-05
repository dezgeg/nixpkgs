{stdenv, lib, fetchurl, coreutils, updateAutoconfGnuConfigScriptsHook }:

stdenv.mkDerivation rec {
  name = "findutils-4.4.2";

  src = fetchurl {
    url = "mirror://gnu/findutils/${name}.tar.gz";
    sha256 = "0amn0bbwqvsvvsh6drfwz20ydc2czk374lzw5kksbh6bf78k4ks3";
  };

  nativeBuildInputs = [ coreutils ] ++ lib.optional stdenv.isAarch64 updateAutoconfGnuConfigScriptsHook;

  patches = [ ./findutils-path.patch ./change_echo_path.patch ./disable-test-canonicalize.patch ];

  doCheck = true;

  crossAttrs = {
    src = fetchurl {
      url = "mirror://gnu/findutils/findutils-4.6.0.tar.gz";
      sha256 = "178nn4dl7wbcw499czikirnkniwnx36argdnqgz4ik9i6zvwkm6y";
    };
    patches = [];
  };

  preConfigure = if stdenv.isCygwin then ''
    sed -i gnulib/lib/fpending.h -e '/include <stdio_ext.h>/d'
  '' else null;

  meta = {
    homepage = http://www.gnu.org/software/findutils/;
    description = "GNU Find Utilities, the basic directory searching utilities of the GNU operating system";

    longDescription = ''
      The GNU Find Utilities are the basic directory searching
      utilities of the GNU operating system.  These programs are
      typically used in conjunction with other programs to provide
      modular and powerful directory search and file locating
      capabilities to other commands.

      The tools supplied with this package are:

          * find - search for files in a directory hierarchy;
          * locate - list files in databases that match a pattern;
          * updatedb - update a file name database;
          * xargs - build and execute command lines from standard input.
    '';

    platforms = stdenv.lib.platforms.all;

    license = stdenv.lib.licenses.gpl3Plus;
  };
}
