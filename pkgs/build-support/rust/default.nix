{ callPackage, fetchurl, stdenv, path, cacert, git, rust, cargo-vendor }:
let
  fetchcargo = import ./fetchcargo.nix {
    inherit stdenv cacert git rust cargo-vendor;
  };
in
{ name, cargoSha256 ? "unset"
, src ? null
, srcs ? null
, sourceRoot ? null
, logLevel ? ""
, buildInputs ? []
, cargoUpdateHook ? ""
, cargoDepsHook ? ""
, cargoBuildFlags ? []

, cargoVendorDir ? null
, ... } @ args:

assert cargoVendorDir == null -> cargoSha256 != "unset";

let
  lib = stdenv.lib;

  cargoDeps = if cargoVendorDir == null
    then fetchcargo {
        inherit name src srcs sourceRoot cargoUpdateHook;
        sha256 = cargoSha256;
      }
    else null;

  setupVendorDir = if cargoVendorDir == null
    then ''
      unpackFile "$cargoDeps"
      cargoDepsCopy=$(stripHash $(basename $cargoDeps))
      chmod -R +w "$cargoDepsCopy"
    ''
    else ''
      cargoDepsCopy="$sourceRoot/${cargoVendorDir}"
    '';

in stdenv.mkDerivation (args // {
  inherit cargoDeps;

  patchRegistryDeps = ./patch-registry-deps;

  buildInputs = [ cacert git rust.cargo rust.rustc ] ++ buildInputs;

  configurePhase = args.configurePhase or ''
    # noop
  '';

  postUnpack = ''
    eval "$cargoDepsHook"

    ${setupVendorDir}

    mkdir .cargo
    cat >.cargo/config <<-EOF
      [source.crates-io]
      registry = 'https://github.com/rust-lang/crates.io-index'
      replace-with = 'vendored-sources'

      [source.vendored-sources]
      directory = '$(pwd)/$cargoDepsCopy'
    EOF

    unset cargoDepsCopy

    export RUST_LOG=${logLevel}
  '' + (args.postUnpack or "");

  buildPhase = with builtins; args.buildPhase or ''
    echo "Running cargo build --release ${concatStringsSep " " cargoBuildFlags}"
    cargo build --release --frozen ${concatStringsSep " " cargoBuildFlags}
  '';

  checkPhase = args.checkPhase or ''
    echo "Running cargo test"
    cargo test
  '';

  doCheck = args.doCheck or true;

  installPhase = args.installPhase or ''
    mkdir -p $out/bin
    find target/release -maxdepth 1 -executable -type f -exec cp "{}" $out/bin \;
  '';

  passthru = { inherit cargoDeps; } // (args.passthru or {});
})
