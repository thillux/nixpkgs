{
  stdenv,
  lib,
  fetchurl,
  gnat,
  gprbuild,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "anet";
  version = "0.5.1";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/libanet-${finalAttrs.version}.tar.bz2";
    hash = "sha256-n2+apIB4t6bGNqZKDe10nDR1BJy/dO+yUagzkJHejjA=";
  };

  # Install the project file where the gprbuild setup hook finds it
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "--project-subdir=lib/gnat" "--project-subdir=share/gpr"
  '';

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  # Selects the architecture specific hardening flags in anet_common.gpr
  env.TARGET_ARCH = stdenv.hostPlatform.parsed.cpu.name;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "OS=linux"
  ];

  preBuild = ''
    makeFlagsArray+=("NUM_CPUS=$NIX_BUILD_CORES")
  '';

  meta = {
    description = "Networking library for Ada";
    homepage = "https://www.codelabs.ch/anet/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.thillux ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
