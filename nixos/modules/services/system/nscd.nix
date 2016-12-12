{ config, lib, pkgs, ... }:

with lib;

let

  nssModulesPath = config.system.nssModules.path;
  cfg = config.services.nscd;

  inherit (lib) singleton;

  cfgFile = pkgs.writeText "nscd.conf" cfg.config;

in

{

  ###### interface

  options = {

    services.nscd = {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the Name Service Cache Daemon.";
      };

      cacheUsers = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable caching of the <literal>passwd</literal> and <literal>group</literal> databases.";
      };

      config = mkOption {
        type = types.lines;
        description = "Configuration to use for Name Service Cache Daemon.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.nscd.config = mkDefault ''
      server-user             nscd
      threads                 1
      paranoia                no
      debug-level             0

      enable-cache            passwd          yes
      positive-time-to-live   passwd          ${if cfg.cacheUsers then "600" else "0"}
      negative-time-to-live   passwd          ${if cfg.cacheUsers then "20" else "0"}
      suggested-size          passwd          211
      check-files             passwd          yes
      persistent              passwd          no
      shared                  passwd          yes

      enable-cache            group           yes
      positive-time-to-live   group           ${if cfg.cacheUsers then "3600" else "0"}
      negative-time-to-live   group           ${if cfg.cacheUsers then "60" else "0"}
      suggested-size          group           211
      check-files             group           yes
      persistent              group           no
      shared                  group           yes

      enable-cache            hosts           yes
      positive-time-to-live   hosts           600
      negative-time-to-live   hosts           5
      suggested-size          hosts           211
      check-files             hosts           yes
      persistent              hosts           no
      shared                  hosts           yes
    '';

    users.extraUsers.nscd =
      { isSystemUser = true;
        description = "Name service cache daemon user";
      };

    systemd.services.nscd =
      { description = "Name Service Cache Daemon";

        wantedBy = [ "nss-lookup.target" "nss-user-lookup.target" ];

        environment = { LD_LIBRARY_PATH = nssModulesPath; };

        preStart =
          ''
            mkdir -m 0755 -p /run/nscd
            rm -f /run/nscd/nscd.pid
            mkdir -m 0755 -p /var/db/nscd
          '';

        restartTriggers = [ config.environment.etc.hosts.source config.environment.etc."nsswitch.conf".source ];

        serviceConfig =
          { ExecStart = "@${pkgs.glibc.bin}/sbin/nscd nscd -f ${cfgFile}";
            Type = "forking";
            PIDFile = "/run/nscd/nscd.pid";
            Restart = "always";
            ExecReload =
              [ "${pkgs.glibc.bin}/sbin/nscd --invalidate passwd"
                "${pkgs.glibc.bin}/sbin/nscd --invalidate group"
                "${pkgs.glibc.bin}/sbin/nscd --invalidate hosts"
              ];
          };

        # Urgggggh... Nscd forks before opening its socket and writing
        # its pid. So wait until it's ready.
        postStart =
          ''
            while ! ${pkgs.glibc.bin}/sbin/nscd -g -f ${cfgFile} > /dev/null; do
              sleep 0.2
            done
          '';
      };

  };
}
