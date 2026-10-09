{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  pkg-config,
  gtk3,
}:

stdenv.mkDerivation {
  pname = "gtkada";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
    pkg-config
  ];

  propagatedBuildInputs = [ gtk3 ];

  # Install the project files where the gprbuild setup hook finds them and
  # skip the testgtk demo, which is not built, and its examples link
  postPatch = ''
    substituteInPlace Makefile.in \
      --replace-fail "lib/gnat" "share/gpr"
    sed -i '/^\tcd testgtk; ''${GPRINSTALL_FULL}/,+2d' Makefile.in
    sed -i '/examples\/gtkada --force$/d' Makefile.in
  '';

  configureFlags = [
    "--disable-static"
    "--with-GL=no"
  ];

  # The Makefile does not support parallel builds, gprbuild parallelizes
  enableParallelBuilding = false;

  makeFlags = [ "PROCESSORS=$(NIX_BUILD_CORES)" ];

  # The default target also builds the testgtk demo
  buildFlags = [
    "relocatable"
    "tools"
  ];

  meta = {
    description = "Ada bindings for GTK+";
    homepage = "https://github.com/AdaCore/gtkada";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
}
