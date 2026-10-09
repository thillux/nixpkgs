{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  which,
  ada-libfswatch,
  gnatcoll-core,
  gnatdoc,
  gnatformat,
  gpr2,
  lal-refactor,
  libadalang-tools,
  spawn,
  vss-extra,
  xdiff,
}:

stdenv.mkDerivation {
  pname = "ada-language-server";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
    which
  ];

  propagatedBuildInputs = [
    ada-libfswatch
    gnatcoll-core
    gnatdoc
    gnatformat
    gpr2
    lal-refactor
    libadalang-tools
    spawn
    vss-extra
    xdiff
  ];

  env.LIBRARY_TYPE = "relocatable";

  makeFlags = [
    "BUILD_MODE=prod"
    "PROCESSORS=$(NIX_BUILD_CORES)"
    "VERSION=${version}"
    "DESTDIR=${placeholder "out"}"
  ];

  # GNAT Studio uses the GLib based LSP client library
  postBuild = ''
    gprbuild -j$NIX_BUILD_CORES -p -P gnat/lsp_client_glib.gpr -XBUILD_MODE=prod
  '';

  postInstall = ''
    gprinstall -p -P gnat/lsp_client_glib.gpr --prefix=$out -XBUILD_MODE=prod
    # Test driver of the testsuite and a copy of a dependency's project
    rm $out/bin/tester-run
    rm -r $out/share/gpr/gnatcoll.gpr $out/share/gpr/manifests/gnatcoll
  '';

  meta = {
    description = "Language server for Ada and SPARK";
    homepage = "https://github.com/AdaCore/ada_language_server";
    license = lib.licenses.gpl3Plus;
    mainProgram = "ada_language_server";
    platforms = lib.platforms.unix;
  };
}
