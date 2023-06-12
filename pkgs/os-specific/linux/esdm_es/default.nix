{ lib, stdenv, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation rec {
  pname = "esdm_es";
  version = "unstable-2023-06-04-${kernel.version}";

  src = fetchFromGitHub {
    owner = "thillux";
    repo = "esdm";
    rev = "bc4f653635dc4522c01aea96d52a5919294564bd";
    hash = "sha256-7tdY9ERPLxMPYpUGQiocxyhlSEZproq+6TRtiPoW+ag=";
  };

  sourceRoot = "source/addon/linux_esdm_es";

  hardeningDisable = [ "format" "pic" ];

  preBuild = ''
    substituteInPlace Makefile --replace "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    sed -i '/depmod/d' Makefile
  '';

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  outputs = [ "out" ];

  makeFlags = kernel.makeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with lib; {
    description = "A kernel module for esdm entropy gathering";
    homepage = "http://www.chronox.de/esdm.html";
    license = [ licenses.gpl2Only licenses.bsd2 ];
    maintainers = with maintainers; [ thillux ];
    platforms = platforms.linux;
    outputsToInstall = [ "out" ];
  };
}
