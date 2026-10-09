{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  gtkada,
}:

stdenv.mkDerivation {
  pname = "spawn";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [ gtkada ];

  env.LIBRARY_TYPE = "relocatable";

  # The default target also builds the tests
  buildPhase = ''
    runHook preBuild
    gprbuild -p -j$NIX_BUILD_CORES -P gnat/spawn.gpr
    gprbuild -p -j$NIX_BUILD_CORES -P gnat/spawn_glib.gpr
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    for project in spawn spawn_glib; do
      gprinstall -p -P gnat/$project.gpr \
        --prefix=$out \
        --sources-subdir=$out/include/$project \
        --lib-subdir=$out/lib/$project \
        --link-lib-subdir=$out/lib
    done
    runHook postInstall
  '';

  meta = {
    description = "Ada library to start processes and communicate with them";
    homepage = "https://github.com/AdaCore/spawn";
    license = with lib.licenses; WITH asl20 llvm-exception;
    platforms = lib.platforms.unix;
  };
}
