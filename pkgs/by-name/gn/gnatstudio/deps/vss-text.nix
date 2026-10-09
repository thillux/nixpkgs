{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
}:

stdenv.mkDerivation {
  pname = "vss-text";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  buildFlags = [ "build-libs-release_relocatable" ];
  installTargets = [ "install-libs-release_relocatable" ];
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Advanced string and text manipulation for Ada";
    homepage = "https://github.com/AdaCore/vss-text";
    license = with lib.licenses; WITH asl20 llvm-exception;
    platforms = lib.platforms.unix;
  };
}
