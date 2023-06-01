{lib, config, pkgs, ... }:

with lib;

let
    cfg = config.services.esdm;
in {
    imports =
        [
        ];

    options.services.esdm = {
        # StartLimitIntervalSec = mkOption {
        #     type = types.str;
        #     default = "500";
        # }
        enable = mkEnableOption "test";

        package = lib.mkOption{
            default = pkgs.esdm;
        };
    };

    config = mkIf cfg.enable {

        systemd.services."esdm-server" = {
            description = "esdm-server test.";

            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                ExecStart = "${cfg.package}/bin/esdm-server -f -vv";
                Restart = "always";
            };
        };

        systemd.services."esdm-cuse-random" = {
            description = "esdm-server test.";

            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                ExecStart = "${cfg.package}/bin/esdm-cuse-random -f -v 7";
                Restart = "always";
            };
        };

        systemd.services."esdm-cuse-urandom" = {
            description = "esdm-server test.";

            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                ExecStart = "${cfg.package}/bin/esdm-cuse-urandom -f";
                Restart = "always";
            };
        };
    };

}