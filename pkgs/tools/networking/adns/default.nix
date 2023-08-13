{ stdenv, fetchgit, gnat, gprbuild, glibc, anet, alog, dbus-ada, glib, dbus-glib }:

stdenv.mkDerivation rec {
  pname = "adns";
  version = "0.1.2";

  src = fetchgit {
    url = "https://git.codelabs.ch/git/adns.git";
    rev = "9682c105c7252976d9b514334c468091fce44e6c";
    sha256 = "sha256-BFVUQSXXUKARM8xrcXU9Hj+K0pDL0cMegFTBx4+HMRk=";
  };

  patches = [
    ./dbus.patch
  ];

  nativeBuildInputs = [
    gprbuild
    gnat
  ];
  buildInputs = [
    alog
    anet
    dbus-ada
    glib
    dbus-glib
  ];

  dontConfigure = true;

  makeFlags = [
    "PREFIX="
    "DESTDIR=${placeholder "out"}"
  ];
}