{ stdenv, fetchurl, autoreconfHook, zlib }:

stdenv.mkDerivation rec {
  name = "kexec-tools-${version}";
  version = "2.0.12";

  src = fetchurl {
    urls = [
      "mirror://kernel/linux/utils/kernel/kexec/${name}.tar.xz"
      "http://horms.net/projects/kexec/kexec-tools/${name}.tar.xz"
    ];
    sha256 = "03cj7w2l5fqn72xfhl4q6z0zbziwkp9bfn0gs7gaf9i44jv6gkhl";
  };

  buildInputs = [ autoreconfHook zlib ];

  patches = stdenv.lib.optional stdenv.isAarch64 (fetchurl {
    url = https://raw.githubusercontent.com/openembedded/openembedded-core/master/meta/recipes-kernel/kexec/kexec-tools/kexec-aarch64.patch;
    sha256 = "0k2v6q21gf3yhrv5xwc63hvd23irqi6zq58qlxb66nq4i4giah95";
  });

  meta = with stdenv.lib; {
    homepage = http://horms.net/projects/kexec/kexec-tools;
    description = "Tools related to the kexec Linux feature";
    platforms = platforms.linux;
    maintainers = with maintainers; [ nckx ];
  };
}
