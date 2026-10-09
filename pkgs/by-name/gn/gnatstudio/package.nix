{
  stdenv,
  lib,
  callPackage,
  fetchFromGitHub,
  autoconf,
  pkg-config,
  wrapGAppsHook3,
  gobject-introspection,
  python312,
  llvmPackages,
  gtk3,
}:

let
  adaPackages = callPackage ./scope.nix { };

  inherit (adaPackages)
    gnat
    gprbuild
    ada-language-server
    gnatcoll-python3
    gnatcoll-sqlite
    gnatcoll-xref
    gtkada
    libadalang-tools
    spawn
    templates-parser
    ;

  # Must be the interpreter gnatcoll-python3 is built against, as it is
  # embedded into GNAT Studio
  python = python312.withPackages (
    ps: with ps; [
      jedi
      pycairo
      pycodestyle
      pygobject3
      pyyaml
      setuptools # distutils, checked for by configure
    ]
  );

  sources = import ./sources.nix;

  inherit (adaPackages.gtkada) version;
in
stdenv.mkDerivation {
  pname = "gnatstudio";
  inherit version;

  src = fetchFromGitHub {
    owner = "AdaCore";
    inherit (sources.gnatstudio) repo rev hash;
  };

  postPatch = ''
    # Release tarballs contain these, configure falls back to 0.0 otherwise
    echo "${version}" > VERSION.txt
    echo "20260409" > DATE.txt

    # The check relies on gtkada-config, which GtkAda does not install
    # anymore. gprbuild finds GtkAda through its project file instead.
    substituteInPlace configure.ac \
      --replace-fail "AM_PATH_GTKADA(" "dnl AM_PATH_GTKADA("

    # Do not build the testsuite drivers
    substituteInPlace Makefile.in \
      --replace-fail '	$(MAKE) -C testsuite BUILD=$(BUILD) $@' ""

    patchShebangs --build .
  '';

  preConfigure = ''
    autoconf
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    gnat
    gprbuild
    pkg-config
    python
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    ada-language-server
    gnatcoll-python3
    gnatcoll-sqlite
    gnatcoll-xref
    gtk3
    gtkada
    libadalang-tools
    python
    python312.pkgs.pygobject3 # pygobject-3.0.pc
    spawn
    templates-parser
  ];

  env.LIBRARY_TYPE = "relocatable";

  makeFlags = [
    "BUILD=Production"
    "OS=unix"
    "PROCESSORS=$(NIX_BUILD_CORES)"
  ];

  preFixup = ''
    # By default, GNAT Studio uses the interpreter of its binary releases in
    # share/gnatstudio/python
    gappsWrapperArgs+=(
      --set GNATSTUDIO_PYTHONHOME "${python}"
    )
  '';

  # Language servers are looked up in libexec before PATH. Linked after the
  # wrapping, which would otherwise wrap them, too.
  postFixup = ''
    mkdir -p $out/libexec/gnatstudio/als $out/libexec/gnatstudio/clang/bin
    ln -s ${lib.getExe ada-language-server} $out/libexec/gnatstudio/als/
    ln -s ${llvmPackages.clang-tools}/bin/clangd $out/libexec/gnatstudio/clang/bin/
  '';

  passthru = {
    inherit adaPackages;
  };

  meta = {
    description = "IDE for Ada, SPARK, C and C++";
    homepage = "https://github.com/AdaCore/gnatstudio";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.thillux ];
    mainProgram = "gnatstudio";
    platforms = lib.platforms.linux;
  };
}
