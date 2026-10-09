{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  gnatcoll-core,
  vss-text,
  xmlada,
}:

stdenv.mkDerivation {
  pname = "vss-extra";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [
    gnatcoll-core
    vss-text
    xmlada
  ];

  env.LIBRARY_TYPE = "relocatable";

  buildFlags = [ "build-libs-release_relocatable" ];
  installTargets = [ "install-libs-release_relocatable" ];
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "JSON, regular expressions, XML and OS abstractions on top of VSS";
    homepage = "https://github.com/AdaCore/vss-extra";
    license = with lib.licenses; WITH asl20 llvm-exception;
    platforms = lib.platforms.unix;
  };
}
