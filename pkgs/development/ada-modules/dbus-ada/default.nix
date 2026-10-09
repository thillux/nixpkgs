{
  stdenv,
  lib,
  fetchurl,
  gnat,
  gprbuild,
  dbus,
  dbus-glib,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dbus-ada";
  version = "0.6.3";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/libdbusada-${finalAttrs.version}.tar.bz2";
    hash = "sha256-x8jM3rEDrgl/1+5mk+B2RqP37kqpQEMNrfu94dYy4fE=";
  };

  # Install the project file where the gprbuild setup hook finds it
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "--project-subdir=lib/gnat" "--project-subdir=share/gpr"
  '';

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  # dbusada.gpr passes these libraries to the linker of every dependent
  propagatedBuildInputs = [
    dbus
    dbus-glib
    glib
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  preBuild = ''
    makeFlagsArray+=("NUM_CPUS=$NIX_BUILD_CORES")
  '';

  meta = {
    description = "Ada bindings for the D-Bus message bus system";
    homepage = "https://www.codelabs.ch/dbus-ada/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.thillux ];
    platforms = lib.platforms.linux;
  };
})
