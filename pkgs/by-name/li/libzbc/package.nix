{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitHub,
  gtk3,
  libtool,
  pkg-config,
  guiSupport ? false,
}:

stdenv.mkDerivation rec {
  pname = "libzbc";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "westerndigitalcorporation";
    repo = "libzbc";
    rev = "v${version}";
    sha256 = "sha256-8+HF5Wf6lQHbi8Vp2tpom1FO56lQ5RyYsgs8ii+2RD0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libtool
  ]
  ++ lib.optionals guiSupport [ pkg-config ];

  buildInputs = lib.optionals guiSupport [ gtk3 ];

  configureFlags = lib.optional guiSupport "--enable-gui";

  meta = with lib; {
    description = "ZBC device manipulation library";
    homepage = "https://github.com/westerndigitalcorporation/libzbc";
    maintainers = [ ];
    license = with licenses; [
      bsd2
      lgpl3Plus
    ];
    platforms = platforms.linux;
  };
}
