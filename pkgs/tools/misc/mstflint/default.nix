{ lib
, stdenv
, fetchurl
, libibmad
, openssl
, zlib
, xz
, expat
, boost
, curl
, pkg-config
, autoreconfHook
, libxml2
, pciutils
, busybox
, python3
, minimalBuild ? false
}:

stdenv.mkDerivation rec {
  pname = "mstflint";
  version = "4.25.0-1";

  src = fetchurl {
    url = "https://github.com/Mellanox/mstflint/releases/download/v${version}/mstflint-${version}.tar.gz";
    hash = "sha256-nYGiWfr8a3q3+bGUb1ovLrAS8/LnEJf+4inIEllW95s=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libibmad
    zlib
    libxml2
    openssl
  ] ++ lib.optional (!minimalBuild) [
    boost.dev
    curl.dev
    expat.dev
    xz.dev
    python3
  ];

  # tracked upstream at
  #  - https://github.com/Mellanox/mstflint/pull/855
  #  - https://github.com/Mellanox/mstflint/issues/856
  # remove if merged
  patches = [
    ./0001-fix-dynamic-linking.patch
    ./0002-fix-mstprivhost.py.patch
    ./0003-fix-mtcr.py.patch
  ];

  preConfigure = ''
    export CPPFLAGS="-I$(pwd)/tools_layouts -isystem ${libxml2.dev}/include/libxml2"
    export INSTALL_BASEDIR=$out
  '';

  # Cannot use wrapProgram since the python script's logic depends on the
  # filename and will get messed up if the executable is named ".xyz-wrapped".
  # That is why the python executable and runtime dependencies are injected
  # this way.
  prePatch = lib.optionals (!minimalBuild) ''
    substituteInPlace common/python_wrapper.sh \
      --replace \
      'exec $PYTHON_EXEC $SCRIPT_PATH "$@"' \
      'export PATH=$PATH:${lib.makeBinPath [ (placeholder "out") pciutils busybox]}; exec ${python3}/bin/python3 $SCRIPT_PATH "$@"'
  '';

  configureFlags = [
    "--enable-xml2"
  ] ++ lib.optional (!minimalBuild) [
    "--enable-dc"
    "--enable-adb-generic-tools"
    "--enable-fw-mgr"
    "--enable-cs"
    "--datarootdir=${placeholder "out"}/share"
  ];

  enableParallelBuilding = true;

  hardeningDisable = [ "format" ];

  dontDisableStatic = true;  # the build fails without this. should probably be reported upstream

  meta = with lib; {
    description = "Open source version of Mellanox Firmware Tools (MFT)";
    homepage = "https://github.com/Mellanox/mstflint";
    license = with licenses; [ gpl2 bsd2 ];
    maintainers = with maintainers; [ thillux ];
    platforms = platforms.linux;
  };
}
