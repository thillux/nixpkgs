{ lib, stdenv, fetchurl, fetchFromGitHub
, git, protobufc, pkgconfig, fuse3, meson, cmake, ninja
, libselinux, jitterentropy }:

stdenv.mkDerivation rec {
  pname = "esdm";
  version = "";

  src = ../../../../../../Documents/repo/esdm;

  nativeBuildInputs = [ meson cmake pkgconfig ninja ];
  buildInputs = [ protobufc fuse3 jitterentropy libselinux ];

  mesonFlags = [
    "-Db_lto=false"
    "-Dselinux=disabled"
  ];

/*  meta = with lib; {
    homepage = "https://www.nano-editor.org/";
    description = "A small, user-friendly console text editor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ joachifm nequissimus ];
    platforms = platforms.all;
  };
*/
}
