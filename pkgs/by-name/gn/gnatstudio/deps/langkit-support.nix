{
  stdenv,
  langkit,
  python3,
  gnat,
  gprbuild,
  adasat,
  gnatcoll-core,
  gnatcoll-gmp,
  gnatcoll-iconv,
  prettier-ada,
}:

# The runtime library of Langkit generated libraries. It is separate from
# langkit, so that dependents do not keep Langkit and Python at runtime.
stdenv.mkDerivation {
  pname = "langkit-support";
  inherit (langkit) version src postUnpack;

  nativeBuildInputs = [
    gnat
    gprbuild
    (python3.withPackages (_: [ langkit ]))
  ];

  propagatedBuildInputs = [
    adasat
    gnatcoll-core
    gnatcoll-gmp
    gnatcoll-iconv
    prettier-ada
  ];

  env.LIBRARY_TYPE = "relocatable";

  buildPhase = ''
    runHook preBuild
    python manage.py build-langkit-support \
      --build-mode=prod \
      --library-types=relocatable \
      --jobs=$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    python manage.py install-langkit-support \
      --build-mode=prod \
      --library-types=relocatable \
      $out
    runHook postInstall
  '';

  meta = langkit.meta // {
    description = "Runtime library of Langkit generated libraries";
  };
}
