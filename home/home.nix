{ config
, pkgs
, inputs
, self
, ...
}:
{
  imports = [
    ./terminal/zsh.nix
    ./terminal/git.nix
    ./terminal/ssh.nix
    self.homeManagerModules.secrets
  ];

  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    EDITOR = "vim";
    CACHIX_AUTH_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.cachix.path} 2>/dev/null)";
    GITHUB_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.github.path} 2>/dev/null)";
  };

  home.packages = with pkgs; [
    gh
    nixpkgs-review
    cachix
    # minicom
    # rkdeveloptool
    nixfmt-rfc-style
    colmena
    inputs.agenix.packages.${config.nixpkgs.system}.default
  ];

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  services.vscode-server = {
    enable = false;
    enableFHS = false;
  };

  home.stateVersion = "24.11";
}
