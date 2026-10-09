# Ada libraries and tools at the revisions GNAT Studio was released with.
# They are kept separate from gnatPackages, which track the tagged releases.
{
  fetchFromGitHub,
  gnatPackages,
}:

let
  sources = import ./sources.nix;

  version = "2026.2";

  fetch =
    name:
    fetchFromGitHub {
      owner = "AdaCore";
      inherit (sources.${name}) repo rev hash;
    };

  pin =
    name: drv:
    drv.overrideAttrs {
      inherit version;
      src = fetch name;
    };
in
gnatPackages.overrideScope (
  final: prev: {
    # gprbuild follows the source of gprbuild-boot. The GNAT 16 fixes of the
    # 25.0.0 release are part of the snapshot.
    gprbuild-boot = (pin "gprbuild" prev.gprbuild-boot).overrideAttrs { patches = [ ]; };

    xmlada = pin "xmlada" prev.xmlada;

    # The GNAT 16 fix of the 25.0.0 release is part of the snapshot
    gnatcoll-core = (pin "gnatcoll-core" prev.gnatcoll-core).overrideAttrs { patches = [ ]; };
    gpr2 =
      (pin "gpr2" (prev.gpr2.override { gpr2kbdir = "${fetch "gprconfig_kb"}/db"; })).overrideAttrs
        {
          # The tools are not needed and only the libraries are installed
          buildFlags = [ "build-libs" ];
          installTargets = [ "install-libs" ];

          # gprinstall adds subunits to the interface of the standalone library,
          # which gprbuild then refuses in dependent projects. Build a regular
          # shared library instead.
          postPatch = ''
            sed -i '/for Library_Interface use/,/"GPR_Parser_Support.Vectors");/d' gpr2.gpr
          '';
        };

    gnatcoll-sql = pin "gnatcoll-db" prev.gnatcoll-sql;
    gnatcoll-sqlite = pin "gnatcoll-db" prev.gnatcoll-sqlite;
    gnatcoll-xref = pin "gnatcoll-db" prev.gnatcoll-xref;

    gnatcoll-gmp = pin "gnatcoll-bindings" prev.gnatcoll-gmp;
    gnatcoll-iconv = pin "gnatcoll-bindings" prev.gnatcoll-iconv;
    gnatcoll-python3 = pin "gnatcoll-bindings" prev.gnatcoll-python3;

    vss-text = final.callPackage ./deps/vss-text.nix {
      inherit version;
      src = fetch "vss-text";
    };
    vss-extra = final.callPackage ./deps/vss-extra.nix {
      inherit version;
      src = fetch "vss-extra";
    };
    adasat = final.callPackage ./deps/adasat.nix {
      inherit version;
      src = fetch "adasat";
    };
    gtkada = final.callPackage ./deps/gtkada.nix {
      inherit version;
      src = fetch "gtkada";
    };
    spawn = final.callPackage ./deps/spawn.nix {
      inherit version;
      src = fetch "spawn";
    };
    ada-libfswatch = final.callPackage ./deps/ada-libfswatch.nix {
      inherit version;
      src = fetch "ada_libfswatch";
    };
    markdown = final.callPackage ./deps/markdown.nix {
      inherit version;
      src = fetch "markdown";
    };
    templates-parser = final.callPackage ./deps/templates-parser.nix {
      inherit version;
      src = fetch "templates_parser";
    };
    xdiff = final.callPackage ./deps/xdiff.nix {
      inherit version;
      src = fetch "xdiff";
    };
    langkit = final.callPackage ./deps/langkit.nix {
      inherit version;
      src = fetch "langkit";
    };
    langkit-support = final.callPackage ./deps/langkit-support.nix { };
    libadalang = final.callPackage ./deps/libadalang.nix {
      inherit version;
      src = fetch "libadalang";
    };
    libadalang-tools = final.callPackage ./deps/libadalang-tools.nix {
      inherit version;
      src = fetch "libadalang-tools";
    };
    gnatformat = final.callPackage ./deps/gnatformat.nix {
      inherit version;
      src = fetch "gnatformat";
    };
    lal-refactor = final.callPackage ./deps/lal-refactor.nix {
      inherit version;
      src = fetch "lal-refactor";
    };
    gnatdoc = final.callPackage ./deps/gnatdoc.nix {
      inherit version;
      src = fetch "gnatdoc";
    };
    ada-language-server = final.callPackage ./deps/ada-language-server.nix {
      inherit version;
      src = fetch "ada_language_server";
    };
    prettier-ada = final.callPackage ./deps/prettier-ada.nix {
      inherit version;
      src = fetch "prettier-ada";
    };
  }
)
