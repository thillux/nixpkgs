{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  vss-extra,
}:

stdenv.mkDerivation {
  pname = "markdown";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [ vss-extra ];

  env.LIBRARY_TYPE = "relocatable";

  makeFlags = [
    "BUILD_MODE=prod"
    "PREFIX=${placeholder "out"}"
  ];

  meta = {
    description = "Markdown parser for Ada";
    homepage = "https://github.com/AdaCore/markdown";
    license = with lib.licenses; WITH asl20 llvm-exception;
    platforms = lib.platforms.unix;
  };
}
