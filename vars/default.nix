{ inputs, ... }:
let
  secret = import "${inputs.secrets}/vars.nix";
in
{
  flake.vars = secret // {
    buildMachines = {
      ft = {
        system = "aarch64-linux";
        sshUser = secret.user.name;
        sshKey = "/run/agenix/id_ed25519";
        hostName = secret.hostIP."ft";
        speedFactor = 8;
        maxJobs = 1;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
        ];
      };
      x79 = {
        system = "x86_64-linux";
        sshUser = secret.user.name;
        sshKey = "/run/agenix/id_ed25519";
        hostName = secret.hostIP."x79";
        speedFactor = 8;
        maxJobs = 1;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
        ];
      };
      mac = {
        system = "aarch64-darwin";
        sshUser = secret.user.name;
        sshKey = "/run/agenix/id_ed25519";
        hostName = secret.hostIP."mac";
        speedFactor = 8;
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
