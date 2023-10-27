{ lib, stdenv, fetchurl, kernel, kmod, coreutils, breakpointHook }:

stdenv.mkDerivation rec {
  pname = "mlnx_ofed";
  version = "2.2.1";

  # a subversion like "23.07-0.5.0.0" cannot really be deduced,
  # every update needs to check for this
  src = fetchurl {
    url = "https://linux.mellanox.com/public/repo/doca/${version}/extras/mlnx_ofed/23.07-0.5.0.0/SOURCES/mlnx-ofed-kernel_23.07.orig.tar.gz";
    hash = "sha256-dWyyDU743zCOkppqSUCA9InmgS+NxbjG3GjNN2yTusA=";
  };

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  preConfigure = ''
    for d in $(find . -type d); do
        patchShebangs $d
    done

    substituteInPlace \
        ofed_scripts/configure \
        compat/config/parallel-build.m4 \
        compat/configure \
        ofed_scripts/makefile \
      --replace "/bin/cp" "${coreutils}/bin/cp"

    substituteInPlace \
        ofed_scripts/configure \
        compat/config/parallel-build.m4 \
        compat/configure \
        ofed_scripts/makefile \
      --replace "/bin/mv" "${coreutils}/bin/mv"

    substituteInPlace \
        ofed_scripts/configure \
        compat/config/parallel-build.m4 \
        compat/configure \
        ofed_scripts/makefile \
      --replace "/bin/rm" "${coreutils}/bin/rm"

    substituteInPlace \
        ofed_scripts/configure \
        compat/config/parallel-build.m4 \
        compat/configure \
        ofed_scripts/makefile \
      --replace "/bin/mkdir" "${coreutils}/bin/mkdir"

    substituteInPlace \
        ofed_scripts/configure \
        compat/config/parallel-build.m4 \
        compat/configure \
        ofed_scripts/makefile \
      --replace "/bin/mktemp" "${coreutils}/bin/mktemp"
    
     substituteInPlace \
        ofed_scripts/configure \
        compat/config/parallel-build.m4 \
        compat/configure \
        ofed_scripts/makefile \
      --replace "/bin/ls" "${coreutils}/bin/ls"
    
    echo $configureFlags
  '';

  configureFlags = [
    "--kernel-version ${kernel.modDirVersion}"
    "--kernel-sources ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/source"
    "--with-linux ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/source"
    "--with-linux-obj ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "--modules-dir ${placeholder "out"}/lib/modules/${kernel.modDirVersion}/"
    "-j100" #$NIX_BUILD_CORES"
    "--with-core-mod"
    "--with-mlx5-mod"
    "--with-user_access-mod"
    "--with-mlxdevm-mod"
    "--without-kernel-fixes"
    "--without-backport-patches"
  ];

  makeFlags = kernel.makeFlags ++ [
    "V=1"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Out of tree driver for Mellanox NICs";
    homepage = "";
    license = [ licenses.gpl2Only ];
    maintainers = with maintainers; [ thillux ];
    platforms = platforms.linux;
  };
}
