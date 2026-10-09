{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  gnatcoll-core,
  vss-text,
}:

stdenv.mkDerivation {
  pname = "prettier-ada";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [
    gnatcoll-core
    vss-text
  ];

  env.LIBRARY_TYPE = "relocatable";

  makeFlags = [
    "BUILD_MODE=prod"
    "LIBRARY_TYPE=relocatable"
    "PROCESSORS=$(NIX_BUILD_CORES)"
    "PREFIX=${placeholder "out"}"
  ];

  buildFlags = [ "lib" ];

  meta = {
    description = "Ada port of the Prettier pretty printing algorithm";
    homepage = "https://github.com/AdaCore/prettier-ada";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
