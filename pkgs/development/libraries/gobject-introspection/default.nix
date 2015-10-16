{ stdenv, fetchurl, glib, flex, bison, pkgconfig, libffi, python
, libintlOrEmpty, autoconf, automake, otool }:
# now that gobjectIntrospection creates large .gir files (eg gtk3 case)
# it may be worth thinking about using multiple derivation outputs
# In that case its about 6MB which could be separated

let
  ver_maj = "1.46";
  ver_min = "0";
in
stdenv.mkDerivation rec {
  name = "gobject-introspection-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/gobject-introspection/${ver_maj}/${name}.tar.xz";
    sha256 = "6658bd3c2b8813eb3e2511ee153238d09ace9d309e4574af27443d87423e4233";
  };
  patches = [ ./absolute_shlib_path.patch ];

  outputs = [ "dev" "out" ];
  outputBin = "dev";
  outputMan = "dev"; # tiny pages

  buildInputs = [ flex bison pkgconfig python setupHook/*move .gir*/ ]
    ++ libintlOrEmpty
    ++ stdenv.lib.optional stdenv.isDarwin otool;
  propagatedBuildInputs = [ libffi glib ];

  preConfigure = ''
    sed 's|/usr/bin/env ||' -i tools/g-ir-tool-template.in
  '';
  configureFlags = [
    # Tests depend on cairo, which is undesirable (it pulls in lots of
    # other dependencies).
    "--disable-tests"
  ];

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    description = "A middleware layer between C libraries and language bindings";
    homepage    = http://live.gnome.org/GObjectIntrospection;
    maintainers = with maintainers; [ lovek323 urkud lethalman ];
    platforms   = platforms.unix;

    longDescription = ''
      GObject introspection is a middleware layer between C libraries (using
      GObject) and language bindings. The C library can be scanned at compile
      time and generate a metadata file, in addition to the actual native C
      library. Then at runtime, language bindings can read this metadata and
      automatically provide bindings to call into the C library.
    '';
  };
}
