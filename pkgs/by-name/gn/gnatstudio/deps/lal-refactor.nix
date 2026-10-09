{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  libadalang-tools,
}:

stdenv.mkDerivation {
  pname = "lal-refactor";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [ libadalang-tools ];

  env.LIBRARY_TYPE = "relocatable";

  makeFlags = [
    "ALL_LIBRARY_TYPES=relocatable"
    "BUILD_MODE=prod"
    "PROCESSORS=$(NIX_BUILD_CORES)"
    "PREFIX=${placeholder "out"}"
  ];

  buildFlags = [ "lib" ];
  installTargets = [ "install-lib" ];

  meta = {
    description = "Libadalang based refactoring tools for Ada";
    homepage = "https://github.com/AdaCore/lal-refactor";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
