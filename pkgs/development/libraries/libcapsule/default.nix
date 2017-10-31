{ stdenv, fetchFromGitHub, autoreconfHook, docbook_xsl, elfutils, gtk_doc, libxslt, pkgconfig }:

stdenv.mkDerivation rec {
  name = "libcapsule-${version}";
  version = "42";

  nativeBuildInputs = [ autoreconfHook docbook_xsl gtk_doc pkgconfig libxslt ];
  buildInputs = [ elfutils ];

  #src = /home/tmtynkky/opt/libcapsule;
  src = fetchFromGitHub {
    owner = "dezgeg";
    repo = "libcapsule";
    rev = "c3041a777b35952ca5343bb092762334c91a59ea";
    sha256 = "1b8raymfxhp3493lmp8xqs1r782qi42jnjqs59ad5ag15xyb1yfw";
  };

  autoreconfFlags = "-ivf";
  preAutoreconf = ''
    mkdir m4
    gtkdocize
  '';

  dontStrip = true;
  NIX_CFLAGS_COMPILE = "-g";

  meta = with stdenv.lib; {
    description = "Segregated run-time linker library";
    homepage = https://git.collabora.com/cgit/user/vivek/libcapsule.git/;
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.dezgeg ];
    platforms = platforms.linux;
  };
}
