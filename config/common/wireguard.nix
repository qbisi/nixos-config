{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
{
  networking = lib.mkIf config.networking.wireguard.enable {
    firewall.allowedUDPPorts = [ 51820 ];
    wireguard.interfaces = {
      wg0 = {
        ips = [ "${self.vars.hosts."${config.networking.hostName}".wgip}/32" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets."wg-${config.networking.hostName}".path;
        peers =
          let
            wgHosts = lib.filterAttrs (_: v: builtins.hasAttr "wgpub" v) self.vars.hosts;
          in
          lib.mapAttrsToList (
            n: v:
            {
              name = n;
              publicKey = v.wgpub;
              allowedIPs = [ "${v.wgip}/32" ];
            }
            // (lib.optionalAttrs (!(self.lib.isPrivateIP v.ip)) {
              endpoint = "${v.ip}:51820";
              persistentKeepalive = 25;
            })
          ) wgHosts;
      };
    };
  };
}
