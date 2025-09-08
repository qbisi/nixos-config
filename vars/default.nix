{ inputs, ... }:
let
  vars = import "${inputs.secrets}/vars.nix";
in
{
  flake.vars = vars // {
    http_proxy = "http://${vars.hosts.e88a.ip}:1080";
  };
}
