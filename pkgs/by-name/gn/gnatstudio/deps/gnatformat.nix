{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  libadalang,
  prettier-ada,
  vss-extra,
}:

stdenv.mkDerivation {
  pname = "gnatformat";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [
    libadalang
    prettier-ada
    vss-extra
  ];

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
    description = "Opinionated code formatter for Ada";
    homepage = "https://github.com/AdaCore/gnatformat";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
}
