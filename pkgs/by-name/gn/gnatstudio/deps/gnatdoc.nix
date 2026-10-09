{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  libadalang,
  markdown,
  vss-extra,
}:

stdenv.mkDerivation {
  pname = "gnatdoc";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [
    libadalang
    markdown
    vss-extra
  ];

  env.LIBRARY_TYPE = "relocatable";

  buildPhase = ''
    runHook preBuild
    gprbuild -j$NIX_BUILD_CORES -p -P gnat/libgnatdoc.gpr
    gprbuild -j$NIX_BUILD_CORES -p -P gnat/gnatdoc.gpr
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    gprinstall -p -P gnat/libgnatdoc.gpr --prefix=$out
    gprinstall -p -P gnat/gnatdoc.gpr --prefix=$out --mode=usage
    runHook postInstall
  '';

  meta = {
    description = "Documentation generator for Ada and SPARK";
    homepage = "https://github.com/AdaCore/gnatdoc";
    license = lib.licenses.gpl3Plus;
    mainProgram = "gnatdoc";
    platforms = lib.platforms.unix;
  };
}
