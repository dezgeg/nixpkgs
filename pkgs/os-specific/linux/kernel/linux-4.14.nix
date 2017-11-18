{ stdenv, hostPlatform, fetchFromGitHub, perl, buildLinux, ... } @ args:

with stdenv.lib;

import ./generic.nix (args // rec {
  version = "4.14";

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  modDirVersion = concatStrings (intersperse "." (take 3 (splitString "." "${version}.0")));

  # branchVersion needs to be x.y
  extraMeta.branch = concatStrings (intersperse "." (take 2 (splitString "." version)));

  src = fetchFromGitHub {
    owner = "dezgeg";
    repo = "linux";
    rev = "8b722d4f1f615bc53a48d1e08fd2d1867005744c";
    sha256 = "0alxzr7farb8z6y7z2y267qn4p60da8ssx576gdq4kdh3kidh07i";
  };
} // (args.argsOverride or {}))
