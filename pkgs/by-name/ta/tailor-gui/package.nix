{
  stdenv,
  lib,
  rustPlatform,
  cargo,
  rustc,
  pkg-config,
  desktop-file-utils,
  appstream-glib,
  wrapGAppsHook4,
  meson,
  ninja,
  libadwaita,
  gtk4,
  tuxedo-rs,
}:
let
  src = tuxedo-rs.src;
  sourceRoot = "${src.name}/tailor_gui";
  pname = "tailor_gui";
  version = "0.2.3";
in
stdenv.mkDerivation {

  inherit
    src
    sourceRoot
    pname
    version
    ;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      sourceRoot
      ;
    hash = "sha256-9jMy23VD+C87hg/TMXGbzAoqx76dhVOkWcQNudSwsYA=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    pkg-config
    desktop-file-utils
    appstream-glib
    wrapGAppsHook4
  ];

  buildInputs = [
    cargo
    rustc
    meson
    ninja
    libadwaita
    gtk4
  ];

  meta = with lib; {
    description = "Rust GUI for interacting with hardware from TUXEDO Computers";
    mainProgram = "tailor_gui";
    longDescription = ''
      An alternative to the TUXEDO Control Center (https://www.tuxedocomputers.com/en/TUXEDO-Control-Center.tuxedo),
      written in Rust.
    '';
    homepage = "https://github.com/AaronErhardt/tuxedo-rs";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      mrcjkb
      xaverdh
    ];
    platforms = platforms.linux;
  };
}
