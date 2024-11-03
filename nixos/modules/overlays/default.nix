{
  disabledModules = [
    "config/swap.nix"
    "services/networking/nat.nix"
    "services/networking/nat-nftables.nix"
  ];
  imports = [
    ./rename.nix
    ./config/swap.nix
    ./services/networking/nat.nix
    ./services/networking/nat-nftables.nix
  ];
}
