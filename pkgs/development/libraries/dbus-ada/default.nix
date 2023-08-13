{ stdenv, fetchurl, gnat, gprbuild, glibc, dbus, glib, dbus-glib }:

stdenv.mkDerivation rec {
  pname = "libdbusada";
  version = "0.6.2";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/${pname}-${version}.tar.bz2";
    hash = "sha256-JILTkEi5mnPv84ZQpn/QlSGWi/5xoC468VUgp8UvKXk=";
  };

  nativeBuildInputs = [
    gprbuild
    gnat
  ];
  buildInputs = [
    dbus
    glib
    dbus-glib
  ];

  dontConfigure = true;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];
}