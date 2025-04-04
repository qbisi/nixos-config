{ inputs, ... }:
let
  vars = import "${inputs.secrets}/vars.nix";
in
{
  flake.vars = vars // {
    buildMachines = {
      ft = {
        system = "aarch64-linux";
        sshUser = "root";
        sshKey = "/run/agenix/hydra_ed25519";
        hostName = vars.hosts.ft.ip;
        maxJobs = 4;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
        ];
      };
      x79 = {
        system = "x86_64-linux";
        sshUser = "root";
        sshKey = "/run/agenix/hydra_ed25519";
        hostName = vars.hosts.x79.ip;
        maxJobs = 4;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
        ];
      };
      mac = {
        system = "aarch64-darwin";
        sshUser = vars.user.name;
        sshKey = "/run/agenix/hydra_ed25519";
        hostName = "mac";
        maxJobs = 1;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
        ];
      };
    };
  };
}
