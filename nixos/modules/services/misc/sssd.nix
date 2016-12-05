{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sssd;
in {
  options = {
    services.sssd = {
      enable = mkEnableOption "Whether to enable the System Security Services daemon.";
      config = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        description = ''
          Contents of <filename>sssd.conf</filename> described as attrset-of-attrsets.
          For instance, the example would generate the following configuration:
          <programlisting>
          [sssd]
          domains = LDAP
          services = nss, pam

          [domain/LDAP]
          id_provider = ldap
          ldap_uri = ldaps://ldap.example.com
          </programlisting>
        '';
        default = {};
        example = {
          sssd = {
            domains = "LDAP";
            services = "nss, pam";
          };
          "domain/LDAP" = {
            id_provider = "ldap";
            ldap_uri = "ldaps://ldap.example.com";
          };
        };
      };
      sshAuthorizedKeysIntegration = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to make sshd look up authorized keys from SSS.
          For this to work, the <literal>ssh</literal> SSS service must be enabled in the sssd configuration.
        '';
      };
    };
  };

  config = mkMerge [(mkIf cfg.enable {
    services.nscd.cacheUsers = false;
    system.nssModules = [ pkgs.sssd ];
    systemd.services.sssd = {
      description = "System Security Services Daemon";
      wantedBy    = [ "multi-user.target" ];
      before = [ "systemd-user-sessions.service" "nss-user-lookup.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      wants = [ "nss-user-lookup.target" ];
      restartTriggers = [ config.environment.etc."sssd.conf".source ];

      script = ''
        mkdir -p /var/lib/sss/{pubconf,db,mc,pipes,gpo_cache} /var/lib/sss/pipes/private /var/lib/sss/pubconf/krb5.include.d
        export LDB_MODULES_PATH=${pkgs.ldb}/modules/ldb:${pkgs.sssd}/modules/ldb
        ${pkgs.sssd}/bin/sssd -D -c /etc/sssd.conf
      '';
      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/sssd.pid";
      };
    };
    environment.etc."sssd.conf" = {
      mode = "0600";
      text = generators.toINI { mkKeyValue = k: v: "${k} = ${toString v}"; } cfg.config;
    };

  }) (mkIf cfg.sshAuthorizedKeysIntegration {
    # Ugly: sshd refuses to start if a store path is given because /nix/store is group-writable.
    # So indirect by a symlink.
    environment.etc."ssh/authorized_keys_command" = {
      mode = "0755";
      text = ''
        #!/bin/sh
        exec ${pkgs.sssd}/bin/sss_ssh_authorizedkeys "$@"
      '';
    };
    services.openssh.extraConfig = ''
        AuthorizedKeysCommand /etc/ssh/authorized_keys_command
        AuthorizedKeysCommandUser nobody
    '';
  })];
}
