{
  lib,
  pkgs,
  config,
  self,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    3000
  ];

  services.hydra = {
    enable = true;
    listenHost = "*";
    hydraURL = "http://${config.networking.fqdnOrHostName}:3000";
    useSubstitutes = true;
    notificationSender = self.vars.user.mail;
    extraConfig = ''
      max_output_size = ${builtins.toString (32 * 1024 * 1024 * 1024)}
    '';
    buildMachinesFiles = [
      "${pkgs.writeText "machine" ''
        localhost ${config.nixpkgs.system} - 4 1 kvm,nixos-test,big-parallel,benchmark - -
      ''}"
      "/etc/nix/machines"
    ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
      ];
    };
    # buildMachines = lib.mkAfter [
    #   {
    #     hostName = "localhost";
    #     system = config.nixpkgs.system;
    #     supportedFeatures = [
    #       "kvm"
    #       "nixos-test"
    #       "big-parallel"
    #       "benchmark"
    #     ];
    #     maxJobs = config.nix.settings.max-jobs;
    #     protocol = null;
    #   }
    # ];
  };
}
