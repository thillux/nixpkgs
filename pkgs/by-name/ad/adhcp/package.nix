{
  stdenv,
  lib,
  fetchurl,
  gnat,
  gnatPackages,
  asciidoc,
  docbook_xml_dtd_45,
  docbook_xsl,
  libxslt,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adhcp";
  version = "0.5.4";

  src = fetchurl {
    url = "https://www.codelabs.ch/download/adhcp-${finalAttrs.version}.tar.bz2";
    hash = "sha256-lnwMQdsA0ZLHDpAL35y8XUbYzntgqwBGkYCIKTUdnt0=";
  };

  # The clients execute the notifiers and the wrapper executes the clients
  postPatch = ''
    substituteInPlace \
      tools/client/adhcp_client.adb \
      tools/client/adhcp_client_wrapper.adb \
      src/v6/dhcpv6-cmd_line.adb \
      --replace-fail "/usr/local/sbin/" "$out/sbin/"

    # setgid directories are not allowed in the store
    substituteInPlace Makefile \
      --replace-fail "install -m 2775 -d" "install -d"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gnat
    gnatPackages.gprbuild
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    libxslt
    installShellFiles
  ];

  buildInputs = with gnatPackages; [
    alog
    anet
    dbus-ada
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    # The substituted store paths exceed the style checked line length
    "ADAFLAGS=-gnatyM200"
  ];

  preBuild = ''
    makeFlagsArray+=("NUM_CPUS=$NIX_BUILD_CORES")
  '';

  postBuild = ''
    make -C doc build_man
  '';

  postInstall = ''
    installManPage doc/man/*.8
  '';

  meta = {
    description = "DHCPv4 and DHCPv6 client and DHCPv4 relay written in Ada";
    homepage = "https://www.codelabs.ch/adhcp/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.thillux ];
    mainProgram = "adhcp_client";
    inherit (gnatPackages.anet.meta) platforms;
  };
})
