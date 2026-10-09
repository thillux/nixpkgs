{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
}:

stdenv.mkDerivation {
  pname = "templates-parser";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
    "DEFAULT_LIBRARY_TYPE=relocatable"
    "ENABLE_SHARED=true"
    "ENABLE_STATIC=false"
    "PRJ_BUILD=Release"
    "PROCESSORS=$(NIX_BUILD_CORES)"
  ];

  # The tools are not needed
  buildFlags = [ "build-relocatable" ];
  installTargets = [ "install-relocatable" ];

  meta = {
    description = "Templates engine for Ada";
    homepage = "https://github.com/AdaCore/templates-parser";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
}
