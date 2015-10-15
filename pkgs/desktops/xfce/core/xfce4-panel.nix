{ stdenv, fetchurl, pkgconfig, intltool, gtk, libxfce4util, libxfce4ui
, libwnck, exo, garcon, xfconf, libstartup_notification
, makeWrapper, xfce4mixer, hicolor_icon_theme
}:
let
  p_name  = "xfce4-panel";
  ver_maj = "4.12";
  ver_min = "0";
in
stdenv.mkDerivation rec {
  name = "${p_name}-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://xfce/src/xfce/${p_name}/${ver_maj}/${name}.tar.bz2";
    sha256 = "1c4p3ckghvsad1sj5v8wmar5mh9cbhail9mmhad2f9pwwb10z4ih";
  };

  patches = [ ./xfce4-panel-datadir.patch ];
  patchFlags = "-p1";

  outputs = [ "dev" "out" "docdev" ];

  buildInputs =
    [ pkgconfig intltool gtk libxfce4util exo libwnck
      garcon xfconf libstartup_notification makeWrapper hicolor_icon_theme
    ] ++ xfce4mixer.gst_plugins;
  propagatedBuildInputs = [ libxfce4ui ];

  postInstall = ''
    wrapProgram "$out/bin/xfce4-panel" \
      --prefix GST_PLUGIN_SYSTEM_PATH : "$GST_PLUGIN_SYSTEM_PATH"
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = http://www.xfce.org/projects/xfce4-panel;
    description = "Xfce panel";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.eelco ];
  };
}

