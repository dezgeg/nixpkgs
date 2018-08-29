{
  mkDerivation
}:

mkDerivation {
  name = "breeze-grub";
  installPhase = ''
    mkdir -p "$out/grub/themes"
    mv breeze "$out/grub/themes"
  '';
}
