{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
}:

stdenv.mkDerivation {
  pname = "xdiff";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  env.LIBRARY_TYPE = "relocatable";

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  meta = {
    description = "Ada bindings to the xdiff library of Git";
    homepage = "https://github.com/AdaCore/xdiff";
    license = with lib.licenses; [
      asl20
      lgpl21Plus
    ];
    platforms = lib.platforms.unix;
  };
}
