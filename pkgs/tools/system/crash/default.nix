{ stdenv, fetchurl, fetchFromGitHub, binutils, bison, bzip2, coreutils
, file, findutils, gdb, gzip, less, ncurses, utillinuxCurses, zlib }:

stdenv.mkDerivation rec {
  name = "crash-${version}";
  version = "7.1.3";

  src = fetchFromGitHub {
    owner = "crash-utility";
    repo = "crash";
    rev = version;
    sha256 = "07ac9hsw490jq5011rkdw6mllrqyiyz7ayd0dmxxcgd0nyagr0as";
  };

  # This software is based on a patched GDB, so a simple dependency is not enough.
  gdbSrc = fetchurl {
    url = "http://ftp.gnu.org/gnu/gdb/gdb-7.6.tar.gz";
    sha256 = "0dma5x8d5d8p7zfww6ddc7bx93pr54kmhga8psq4w46cbnd3hw40";
  };

  buildInputs = [ bison ncurses zlib ];

  patchPhase = ''
    substituteInPlace gdb-7.6.patch --replace /bin/cat cat
    for f in *.c crash.8; do
      sed -i $f \
        -e 's|/bin/bunzip2|${bzip2}/bin/bunzip2|' \
        -e 's|/bin/cat|${coreutils}/bin/cat|' \
        -e 's|/bin/echo|${coreutils}/bin/echo|' \
        -e 's|/bin/gunzip|${gzip}/bin/gunzip|' \
        -e 's|/bin/more|${utillinuxCurses}/bin/more|' \
        -e 's|/usr/bin/bunzip2|${bzip2}/bin/bunzip2|' \
        -e 's|/usr/bin/file|${file}/bin/file|' \
        -e 's|/usr/bin/find|${findutils}/bin/find|' \
        -e 's|/usr/bin/gdb|${gdb}/bin/gdb|' \
        -e 's|/usr/bin/gunzip|${gzip}/bin/gunzip|' \
        -e 's|/usr/bin/gzip|${gzip}/bin/gzip|' \
        -e 's|/usr/bin/less|${less}/bin/less|' \
        -e 's|/usr/bin/ls|${coreutils}/bin/ls|' \
        -e 's|/usr/bin/nm|${binutils}/bin/nm|' \
        -e 's|/usr/bin/strings|${binutils}/bin/strings|' \
        -e 's|/usr/bin/tty|${coreutils}/bin/tty|'
    done
  '';

  # Copy the gdb tarball so that the makefile finds it
  configurePhase = ''
    stripHash $gdbSrc
    cp $gdbSrc $strippedName
  '';

  makeFlags = [ "GDB_CONF_FLAGS=CFLAGS=-Wno-error" ];

  installPhase = ''
    mkdir -p $out/bin/
    cp crash $out/bin/
    mkdir -p $out/share/man/man8/
    cp crash.8 $out/share/man/man8/
  '';

  meta = with stdenv.lib; {
    description = "Linux kernel crash dump analysis tool";
    homepage = http://people.redhat.com/~anderson/;
    license = licenses.gpl2;
    maintainers = [ maintainers.dezgeg ];
    platforms = platforms.linux;
  };
}
