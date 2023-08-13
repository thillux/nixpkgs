{ stdenv, fetchurl, gnat, gprbuild, glibc }:

stdenv.mkDerivation rec {
  pname = "libalog";
  version = "0.6.2";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/${pname}-${version}.tar.bz2";
    hash = "sha256-T29BqoX33sS8K04QomlXUUJH7uS1pJh2L92rFxR2hCU=";
  };

  nativeBuildInputs = [
    gprbuild
    gnat
  ];

  dontConfigure = true;

  makeFlags = [
    "PREFIX="
    "DESTDIR=${placeholder "out"}"
  ];
}