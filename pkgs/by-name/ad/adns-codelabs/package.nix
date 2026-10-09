{
  stdenv,
  lib,
  fetchgit,
  gnat,
  gnatPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adns-codelabs";
  version = "0.1.2-unstable-2026-09-11";

  # The latest release does not build against current D_Bus/Ada
  src = fetchgit {
    url = "https://git.codelabs.ch/git/adns.git";
    rev = "6da499b48f332f20c8c6f85bcb7c067740f7486a";
    hash = "sha256-9hLbFjWfiIugf8URNGLb0+RIcJZJSwAnCVuuSzTSE5c=";
  };

  # The version is normally taken from git describe
  postPatch = ''
    echo "${finalAttrs.version}" > .version

    # setgid directories are not allowed in the store
    substituteInPlace Makefile \
      --replace-fail "install -m 2775 -d" "install -d"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gnat
    gnatPackages.gprbuild
  ];

  buildInputs = with gnatPackages; [
    alog
    anet
    dbus-ada
  ];

  preBuild = ''
    makeFlagsArray+=("NUM_CPUS=$NIX_BUILD_CORES")
  '';

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  meta = {
    description = "DNS stub resolver written in Ada, providing a systemd-resolved compatible D-Bus service";
    homepage = "https://www.codelabs.ch/adns/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.thillux ];
    mainProgram = "adns_resolve_cli";
    inherit (gnatPackages.anet.meta) platforms;
  };
})
