{ stdenv, fetchurl, gnat, gprbuild, glibc, anet, alog, dbus-ada }:

stdenv.mkDerivation rec {
  pname = "adhcp";
  version = "0.5.3";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/${pname}-${version}.tar.bz2";
    hash = "sha256-i9/a0TcWDCJhWB5CPmnIS3ZI5xwOyd1g22kCthD07oE=";
  };

  nativeBuildInputs = [
    gprbuild
    gnat
  ];
  buildInputs = [
    alog
    anet
    dbus-ada
  ];

  dontConfigure = true;

  makeFlags = [
    "PREFIX="
    "DESTDIR=${placeholder "out"}"
  ];
}