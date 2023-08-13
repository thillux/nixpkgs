{ stdenv, fetchurl, gnat, gprbuild, glibc }:

stdenv.mkDerivation rec {
  pname = "libanet";
  version = "0.4.3";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/${pname}-${version}.tar.bz2";
    hash = "sha256-8rQdjng/vHOnMZNjmOSp7mCU45kQmYbeqOLcZEv/abU=";
  };

  nativeBuildInputs = [
    gprbuild
    gnat
  ];

  makeFlags = [
    "PREFIX="
    "DESTDIR=${placeholder "out"}"
  ];

  dontConfigure = true;
}