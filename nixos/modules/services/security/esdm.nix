{lib, config, pkgs, ... }:

with lib;

let
    cfg = config.services.esdm;
in {
    imports =
        [
        ];

    options.services.esdm = {
        enable = mkEnableOption "esdm service";

        package = lib.mkOption{
            default = pkgs.esdm;
        };
    };

    config = mkIf cfg.enable {

        systemd.services."esdm-server" = {
            description = "Entropy Source and DRNG Manager Daemon";

            wantedBy = [ "basic.target" ];
            before= [ "sysinit.target" ];
            after = [
                "local-fs.target"
            ];

            serviceConfig = {
                DeviceAllow = [
                    "/dev/null rw"
                    "/dev/hwrng r"
                ];
                DevicePolicy = "strict";
                Restart = "on-failure";
                RestartSec = "5s";
                ExecStart = "${cfg.package}/bin/esdm-server -f";
                IPAddressDeny = "any";
                LimitMEMLOCK = "0";
                LockPersonality = "yes";
                MemoryDenyWriteExecute = "yes";
                MountFlags = "private";
                NoNewPrivileges = "yes";
                PrivateMounts = "yes";
                PrivateNetwork = "yes";
                PrivateTmp = "yes";
                PrivateUsers = "no";
                ProtectControlGroups = "yes";
                ProtectHome = "yes";
                ProtectKernelModules = "yes";
                ProtectKernelTunables = "yes";
                ProtectSystem = "strict";
                ReadOnlyPaths = "-/";
                RemoveIPC = "yes";
                RestrictAddressFamilies = "";
                RestrictRealtime = "yes";
                UMask = "0077";
            };
        };

        systemd.services."esdm-cuse-random" = {
            description = "Entropy Source and DRNG Manager /dev/random";

            wantedBy = [ "basic.target" ];
            wants = [ "esdm-server.service" ];
            before= [ "sysinit.target" ];
            after = [
                "local-fs.target"
                "esdm-server.service"
            ];
            serviceConfig = {
                ExecStart = "${cfg.package}/bin/esdm-cuse-random -f";
                Restart = "on-failure";
                RestartSec = "5s";
            };
        };

        systemd.services."esdm-cuse-urandom" = {
            description = "Entropy Source and DRNG Manager /dev/urandom";

            wantedBy = [ "basic.target" ];
            wants = [ "esdm-server.service" ];
            before= [ "sysinit.target" ];
            after = [
                "local-fs.target"
                "esdm-server.service"
            ];
            serviceConfig = {
                ExecStart = "${cfg.package}/bin/esdm-cuse-urandom -f";
                Restart = "on-failure";
                RestartSec = "5s";
            };
        };

        systemd.services."esdm-proc" = {
            description = "Entropy Source and DRNG Manager /proc/sys/kernel/random";

            wantedBy = [ "basic.target" ];
            wants = [ "esdm-server.service" ];
            before= [ "sysinit.target" ];
            after = [
                "local-fs.target"
                "esdm-server.service"
            ];
            serviceConfig = {
                ExecStart = "${cfg.package}/bin/esdm-proc -d -f -o allow_other /proc/sys/kernel/random";
                Restart = "on-failure";
                RestartSec = "5s";
            };
        };
    };

}