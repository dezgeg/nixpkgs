{ stdenv, fetchurl, pkgs, augeas, bind, c-ares, cyrus_sasl, ding-libs, libnl,
  libunistring, nss, samba, libnfsidmap, doxygen, python, python3,
  pam, popt, talloc, tdb, tevent, pkgconfig, ldb, openldap, pcre, kerberos,
  cifs_utils, glib, keyutils, dbus, fakeroot, libxslt, libxml2,
  docbook_xml_xslt, ldap, systemd, nspr, check, cmocka, http-parser, jansson,
  uid_wrapper, nss_wrapper, docbook_xml_dtd_44, ncurses, Po4a }:

stdenv.mkDerivation rec {
  name = "sssd-${version}";
  version = "1.14.2";

  src = fetchurl {
    url = "https://fedorahosted.org/released/sssd/${name}.tar.gz";
    sha256 = "0vbjsz6r81w0d8rigd37dq1x9z8bc2fnp6w8lk0f0f7mrpnn11l6";
  };

  outputs = [ "out" "dev" "man" ];

  # TODO:
  #  - get tests to pass (memberof.so ldb module can't find libtalloc.so.2)
  #  - get python stuff to work (sss_obfuscate isn't wrapped correctly)

  buildInputs = [
    augeas
    bind
    c-ares
    cifs_utils
    cyrus_sasl
    dbus
    ding-libs
    fakeroot
    glib
    http-parser
    jansson
    kerberos
    keyutils
    ldb
    libnfsidmap
    libnl
    libunistring
    libxml2
    libxslt
    ncurses
    nspr
    nss
    nss_wrapper
    openldap
    pam
    pcre
    pkgconfig
    Po4a
    popt
    /* python python3 */
    samba
    systemd
    talloc
    tdb
    tevent
    uid_wrapper
  ] ++ stdenv.lib.optionals doCheck [ check cmocka ];

  patchPhase = ''
    patchShebangs src/tests
  '';

  preConfigure = ''
    export SGML_CATALOG_FILES="${pkgs.docbook_xml_xslt}/share/xml/docbook-xsl/catalog.xml:${pkgs.docbook_xml_dtd_44}/xml/dtd/docbook/catalog.xml"

    makeFlagsArray+=("SGML_CATALOG_FILES=$SGML_CATALOG_FILES")
    configureFlagsArray+=(
      "--enable-pammoddir=$out/lib/security"
      "--with-xml-catalog-path=''${SGML_CATALOG_FILES%%:*}"
      "--with-ldb-lib-dir=$out/modules/ldb"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-os=fedora"
    "--with-pid-path=/run"
    "--without-python2-bindings"
    "--without-python3-bindings"
    "--with-syslog=journald"
    "--without-selinux"
    "--without-semanage"
  ];

  enableParallelBuilding = true;

  # Something is looking for <libxml/foo.h> instead of <libxml2/libxml/foo.h>
  NIX_CFLAGS_COMPILE = "-I${libxml2.dev}/include/libxml2";

  doCheck = false;

  installPhase = ''
    make install \
      sysconfdir="$out/etc" \
      localstatedir="$TMPDIR" \
      pidpath="$TMPDIR" \
      sss_statedir="$TMPDIR" \
      logpath="$TMPDIR" \
      pubconfpath="$TMPDIR" \
      dbpath="$TMPDIR" \
      mcpath="$TMPDIR" \
      pipepath="$TMPDIR" \
      gpocachepath="$TMPDIR" \
      initdir="$TMPDIR" \
      secdbpath="$TMPDIR"

    find "$out" -depth -type d -exec rmdir --ignore-fail-on-non-empty {} \;
  '';

  meta = {
    description = "System Security Services Daemon";
    homepage = https://fedorahosted.org/sssd/;
    license = stdenv.lib.licenses.gpl3;
  };
}
