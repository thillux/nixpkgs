let
  nixpkgs = import ./default.nix;
  pkgs = nixpkgs {
    system = "aarch64-linux";
    #hostPlatform.system = "aarch64-linux";
    #buildPlatform.system = "x86_64-linux";
  };

  customKernel = let baseKernel = pkgs.linux_latest;
      in pkgs.linuxManualConfig rec {
        inherit (pkgs) stdenv lib;
        inherit (baseKernel) src modDirVersion;
        version = "${baseKernel.version}-bf2";
        configfile = ./kernel.config;
        allowImportFromDerivation = true;
      };

  myisoconfig = { pkgs, lib, ... }: {
        imports = [
          ./nixos/modules/installer/netboot/netboot-minimal.nix
        ];

        boot.kernelPackages = pkgs.linuxPackagesFor customKernel;
        boot.initrd.availableKernelModules = lib.mkOverride 10 [];

        netboot.squashfsCompression = "zstd -Xcompression-level 6";

        documentation.man.enable = lib.mkOverride 10 false;

        boot.supportedFilesystems = pkgs.lib.mkForce [ "btrfs" "vfat" ];

        system.stateVersion = "22.11";
      };

  config = (pkgs.nixos ([ myisoconfig ])).config;
in {
  bf2-bfb = pkgs.callPackage ./nixos/lib/make-bfb.nix {
    kernel = "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";
    initrd = "${config.system.build.netbootRamdisk}/initrd";
    init = "${config.system.build.toplevel}/init";
  };
  
  kernelConfigEnv = (pkgs.linuxPackagesFor customKernel).kernel.overrideAttrs (o: {nativeBuildInputs=o.nativeBuildInputs ++ [ pkgs.pkg-config pkgs.ncurses ];});
}
