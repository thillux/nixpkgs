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

  preBuild = ''
    sed -i "s/--project-subdir=lib\/gnat/--project-subdir=share\/gpr/g" Makefile
  '';

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];
}