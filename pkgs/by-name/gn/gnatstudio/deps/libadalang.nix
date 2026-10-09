{
  stdenv,
  lib,
  src,
  version,
  python3,
  gnat,
  gprbuild,
  langkit,
  langkit-support,
  gnatcoll-core,
  gnatcoll-gmp,
  gnatcoll-iconv,
  gpr2,
  xmlada,
}:

let
  # langkit is a Python package built with the same interpreter
  python = python3.withPackages (_: [ langkit ]);
in
stdenv.mkDerivation {
  pname = "libadalang";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
    python
  ];

  propagatedBuildInputs = [
    langkit-support
    gnatcoll-core
    gnatcoll-gmp
    gnatcoll-iconv
    gpr2
    xmlada
  ];

  env.LIBRARY_TYPE = "relocatable";

  buildPhase = ''
    runHook preBuild
    python -m langkit.scripts.lkm generate
    python -m langkit.scripts.lkm build \
      --build-mode=prod \
      --library-types=relocatable \
      --jobs=$NIX_BUILD_CORES \
      --disable-all-mains
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    python -m langkit.scripts.lkm install \
      --build-mode=prod \
      --library-types=relocatable \
      --disable-all-mains \
      $out
    # Bindings for other languages, the Python based playground and GDB
    # helpers, which would keep the build time Python environment
    rm -r $out/python $out/ocaml $out/java $out/bin $out/share/examples
    rm $out/share/libadalang/gdbinit.py
    runHook postInstall
  '';

  meta = {
    description = "Library for parsing and semantic analysis of Ada code";
    homepage = "https://github.com/AdaCore/libadalang";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
