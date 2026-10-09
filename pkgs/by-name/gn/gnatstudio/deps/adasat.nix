{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
}:

stdenv.mkDerivation {
  pname = "adasat";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  makeFlags = [
    "BUILD_MODE=prod"
    "LIBRARY_TYPE=relocatable"
    "PROCESSORS=$(NIX_BUILD_CORES)"
  ];

  buildFlags = [ "lib" ];

  # The install target installs all library kinds, only one is built
  installPhase = ''
    runHook preInstall
    gprinstall -P adasat.gpr -p -f \
      -XLIBRARY_TYPE=relocatable \
      -XBUILD_MODE=prod \
      --prefix=$out \
      --build-name=relocatable \
      --build-var=LIBRARY_TYPE
    runHook postInstall
  '';

  meta = {
    description = "SAT solver written in Ada";
    homepage = "https://github.com/AdaCore/adasat";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
