{ fetchurl, stdenv }:

stdenv.mkDerivation rec {
  name = "libsigsegv-2.10";

  src = fetchurl {
    url = "mirror://gnu/libsigsegv/${name}.tar.gz";
    sha256 = "16hrs8k3nmc7a8jam5j1fpspd6sdpkamskvsdpcw6m29vnis8q44";
  };

  # https://github.com/NixOS/nixpkgs/issues/6028
  doCheck = false;

  postPatch = if stdenv.isAarch64 then ''
    substituteInPlace configure --replace a29k aarch64
    cp ${../../../../config.guess} build-aux/config.guess
    cp ${../../../../config.sub} build-aux/config.sub
  '' else null;

  meta = {
    homepage = http://www.gnu.org/software/libsigsegv/;
    description = "Library to handle page faults in user mode";

    longDescription = ''
      GNU libsigsegv is a library for handling page faults in user mode. A
      page fault occurs when a program tries to access to a region of memory
      that is currently not available. Catching and handling a page fault is
      a useful technique for implementing pageable virtual memory,
      memory-mapped access to persistent databases, generational garbage
      collectors, stack overflow handlers, distributed shared memory, and
      more.
    '';

    license = stdenv.lib.licenses.gpl2Plus;

    maintainers = [ ];
  };
}
