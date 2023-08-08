{ lib, stdenv
, fetchFromGitHub
, meson
, ninja
, writeText
}:

stdenv.mkDerivation rec {
  pname = "frozen";
  version = "unstable-2021-02-23";

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "frozen";
    rev = "21f051e3abc2240d9a25b2add6629b38e963e102";
    sha256 = "sha256-BpuYK9fbWSpeF8iPT8ImrV3CKKaA5RQ2W0ZQ03TciR0=";
  };

  buildInputs = [];
  nativeBuildInputs = [ meson ninja ];

  mesonBuildFile = writeText "meson.build" ''
    project(
        'frozen',
        'c',
        default_options: [
            'c_args=-Wextra -fno-builtin -pedantic',
            'c_std=c99',
            'werror=true'
        ],
        license: 'Apache-2.0',
        version: '20210223'
    )

    library(
        'frozen',
        'frozen.c',
        install: true
    )

    install_headers('frozen.h')
  '';

  preConfigure = ''
    cp $mesonBuildFile meson.build
  '';

  meta = with lib; {
    homepage = "https://github.com/cesanta/frozen";
    description = "minimal JSON parser for C, targeted for embedded systems";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ thillux ];
  };
}
