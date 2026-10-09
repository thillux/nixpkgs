{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  libuuid,
  libxcrypt-legacy,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
}:

let
  version = "2026.2-20260409";

  srcs = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-QBeqZpglNzLbthHR94SEaj/VCK50vQl5teUPAgdAL7c=";
    };
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-WHe75u7ZOe7Xqb3rq7vLtQ3IwnmSL5VYkC/igSRG4As=";
    };
  };

  src' =
    srcs.${stdenv.hostPlatform.system}
      or (throw "gnatstudio-bin: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "gnatstudio-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/AdaCore/gnatstudio/releases/download/gnatstudio-${version}/gnatstudio-${version}-${src'.arch}-linux-bin.tar.gz";
    inherit (src') hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  # Everything else, including GTK and Python, is bundled
  buildInputs = [
    libuuid
    libxcrypt-legacy
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
  ];

  autoPatchelfIgnoreMissingDeps = [
    # libharfbuzz-icu is bundled but not used by GNAT Studio
    "libicuuc.so.50"
    # dbm and nis modules of the bundled Python interpreters
    "libgdbm.so.4"
    "libgdbm_compat.so.4"
    "libnsl.so.1"
  ];

  # Run explicitly in postFixup, as the bundled tools are used afterwards
  dontAutoPatchelf = true;

  dontConfigure = true;
  dontBuild = true;
  # Stripping the bundled libraries is slow and of little use
  dontStrip = true;

  # The launcher script derives the installation root from its own location,
  # so keep the tree together and wrap the launcher instead of symlinking it.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/gnatstudio
    cp -r bin etc include lib libexec share $out/opt/gnatstudio/

    # GIO modules of the host are built against a different GLib than the
    # bundled one and crash the application when loaded
    for prog in gnatstudio gnatstudio_cli gnatdoc gnatinspect; do
      makeWrapper $out/opt/gnatstudio/bin/$prog $out/bin/$prog \
        --unset GIO_EXTRA_MODULES
    done

    install -Dm644 share/gnatstudio/icons/hicolor/32x32/apps/gnatstudio_logo.png \
      $out/share/icons/hicolor/32x32/apps/gnatstudio.png

    runHook postInstall
  '';

  # The shipped pixbuf loader cache refers to the paths of the upstream build
  # machine and lacks the SVG loader, without which GTK finds no icons at all.
  postFixup = ''
    autoPatchelf $out

    pixbuf=$out/opt/gnatstudio/lib/gnatstudio/gdk-pixbuf-2.0/2.10.0
    LD_LIBRARY_PATH=$out/opt/gnatstudio/lib/gnatstudio \
    GDK_PIXBUF_MODULEDIR=$pixbuf/loaders \
      $out/opt/gnatstudio/bin/gdk-pixbuf-query-loaders > $pixbuf/loaders.cache
    grep -q '"svg"' $pixbuf/loaders.cache

    # Precompile the plugins, which are otherwise compiled on every start
    # (printing warnings) as the store is read-only. The bytecode has to be
    # hash-based, as the store resets the timestamps of the sources.
    $out/opt/gnatstudio/share/gnatstudio/python/bin/python3 -m compileall -q \
      --invalidation-mode unchecked-hash \
      $out/opt/gnatstudio/share/gnatstudio/{support,plug-ins,library}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gnatstudio";
      desktopName = "GNAT Studio";
      genericName = "Ada IDE";
      comment = "IDE for Ada, SPARK, C and C++";
      exec = "gnatstudio %F";
      icon = "gnatstudio";
      categories = [
        "Development"
        "IDE"
      ];
    })
  ];

  meta = {
    description = "IDE for Ada, SPARK, C and C++ (binary release)";
    homepage = "https://github.com/AdaCore/gnatstudio";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.thillux ];
    mainProgram = "gnatstudio";
    platforms = lib.attrNames srcs;
  };
}
