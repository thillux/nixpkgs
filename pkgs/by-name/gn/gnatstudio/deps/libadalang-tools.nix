{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  which,
  libadalang,
  templates-parser,
  vss-extra,
}:

stdenv.mkDerivation {
  pname = "libadalang-tools";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
    which
  ];

  propagatedBuildInputs = [
    libadalang
    templates-parser
    vss-extra
  ];

  env.LIBRARY_TYPE = "relocatable";

  makeFlags = [
    "ALL_LIBRARY_TYPES=relocatable"
    "BUILD_MODE=prod"
    "PROCESSORS=$(NIX_BUILD_CORES)"
    "DESTDIR=${placeholder "out"}"
  ];

  # Only the library is needed, not the tools (gnatpp, gnatstub, ...)
  buildFlags = [ "lib" ];
  installTargets = [ "install-lib" ];

  meta = {
    description = "Libadalang based tools and library for Ada code transformations";
    homepage = "https://github.com/AdaCore/libadalang-tools";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
}
