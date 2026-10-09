{
  stdenv,
  lib,
  fetchurl,
  gnat,
  gprbuild,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alog";
  version = "0.6.2";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/libalog-${finalAttrs.version}.tar.bz2";
    hash = "sha256-T29BqoX33sS8K04QomlXUUJH7uS1pJh2L92rFxR2hCU=";
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

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  preBuild = ''
    makeFlagsArray+=("NUM_CPUS=$NIX_BUILD_CORES")
  '';

  meta = {
    description = "Stackable logging framework for Ada";
    homepage = "https://www.codelabs.ch/alog/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.thillux ];
    platforms = lib.platforms.unix;
  };
})
