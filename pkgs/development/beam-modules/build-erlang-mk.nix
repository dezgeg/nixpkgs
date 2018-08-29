{ stdenv, writeText, erlang, perl, which, gitMinimal, wget, lib }:

{ name, version
, src
, setupHook ? null
, buildInputs ? []
, beamDeps ? []
, postPatch ? ""
, compilePorts ? false
, installPhase ? null
, buildPhase ? null
, configurePhase ? null
, meta ? {}
, enableDebugInfo ? false
, ... }@attrs:

with stdenv.lib;

let
  debugInfoFlag = lib.optionalString (enableDebugInfo || erlang.debugInfo) "+debug_info";

  shell = drv: stdenv.mkDerivation {
          name = "interactive-shell-${drv.name}";
          buildInputs = [ drv ];
    };

  pkg = self: stdenv.mkDerivation ( attrs // {
    app_name = "${name}";
    name = "${name}-${version}";
    inherit version;

    dontStrip = true;

    inherit src;

    setupHook = if setupHook == null
    then writeText "setupHook.sh" ''
       addToSearchPath ERL_LIBS "$1/lib/erlang/lib"
    ''
    else setupHook;

    buildInputs = [ erlang perl which gitMinimal wget ];
    propagatedBuildInputs = beamDeps;

    configurePhase = if configurePhase == null
    then ''
      # We shouldnt need to do this, but it seems at times there is a *.app in
      # the repo/package. This ensures we start from a clean slate
      make SKIP_DEPS=1 clean
    ''
    else configurePhase;

    buildPhase = if buildPhase == null
    then ''
        make SKIP_DEPS=1 ERL_OPTS="$ERL_OPTS ${debugInfoFlag}"
    ''
    else buildPhase;

    installPhase =  if installPhase == null
    then ''
        mkdir -p $out/lib/erlang/lib/${name}
        cp -r ebin $out/lib/erlang/lib/${name}/
        cp -r src $out/lib/erlang/lib/${name}/

        if [ -d include ]; then
          cp -r include $out/lib/erlang/lib/${name}/
        fi

        if [ -d priv ]; then
          cp -r priv $out/lib/erlang/lib/${name}/
        fi

        if [ -d doc ]; then
          cp -r doc $out/lib/erlang/lib/${name}/
        fi
    ''
    else installPhase;

    passthru = {
      packageName = name;
      env = shell self;
      inherit beamDeps;
    };
});
in fix pkg
