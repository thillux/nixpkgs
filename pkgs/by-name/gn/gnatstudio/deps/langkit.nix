{
  lib,
  src,
  version,
  adasat,
  python3Packages,
  gnat,
  gprbuild,
  gnatcoll-core,
  gnatcoll-gmp,
  gnatcoll-iconv,
  prettier-ada,
}:

python3Packages.buildPythonPackage {
  pname = "langkit";
  inherit src version;
  pyproject = true;

  # Generated libraries embed a renamed copy of AdaSAT, which is shipped as
  # package data
  postUnpack = ''
    cp -r ${adasat.src} $sourceRoot/langkit/adasat
    chmod -R u+w $sourceRoot/langkit/adasat
  '';

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.1.0"' 'version = "${version}"'
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    docutils
    e3-core
    funcy
    mako
    pyyaml
  ];

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [
    adasat
    gnatcoll-core
    gnatcoll-gmp
    gnatcoll-iconv
    prettier-ada
  ];

  env.LIBRARY_TYPE = "relocatable";

  # Build Langkit_Support and Liblktlang, the library for the Lkt language
  # that Langkit uses for language specifications.
  postBuild = ''
    python manage.py make \
      --build-mode=prod \
      --library-types=relocatable \
      --jobs=$NIX_BUILD_CORES \
      --no-mypy
  '';

  postInstall = ''
    python manage.py install-langkit-support \
      --build-mode=prod \
      --library-types=relocatable \
      $out
    python -m langkit.scripts.lkm install \
      -c lkt/langkit.yaml \
      --build-mode=prod \
      --library-types=relocatable \
      --disable-all-mains \
      $out

    # The generated Python bindings load the shared library from their own
    # directory if it is there
    mv $out/python/liblktlang $out/${python3Packages.python.sitePackages}/
    rm -r $out/python

    # The Ada libraries are only used by the Python bindings. Dependents use
    # langkit-support, which does not keep Python at runtime.
    rm -r $out/share/gpr
    ln -s $out/lib/liblktlang.so \
      $out/${python3Packages.python.sitePackages}/liblktlang/
  '';

  pythonImportsCheck = [
    "langkit"
    "liblktlang"
  ];

  meta = {
    description = "Compiler for syntactic and semantic language analysis libraries";
    homepage = "https://github.com/AdaCore/langkit";
    license = with lib.licenses; [
      asl20
      gpl3Plus
    ];
    platforms = lib.platforms.unix;
  };
}
