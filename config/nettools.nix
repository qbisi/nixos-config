{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ethtool
    nftables
    dnsutils
    iperf3
    nload
    termshark
  ];

  users.groups.wireshark.members = [ config.users.users.admin.name ];
  security.wrappers.termshark = {
    source = "${pkgs.termshark}/bin/termshark";
    capabilities = "cap_net_raw,cap_net_admin+eip";
    owner = "root";
    group = "wireshark";
    permissions = "u+rx,g+x";
  };
}
