{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./qbisi.nix
  ];

  home.sessionVariables = {
    # MESA_GLSL_VERSION_OVERRIDE = 330;
    http_proxy = "http://127.0.0.1:1080";
    https_proxy = "http://127.0.0.1:1080";
  };

  services.ssh-agent.enable = true;

  programs.ssh.matchBlocks."github.com".proxyJump = "sl2";

  programs.ssh.matchBlocks."ody".proxyCommand = "nc -x 127.0.0.1:1080 -X 5 %h %p";
  programs.ssh.matchBlocks."x79".proxyCommand = "nc -x 127.0.0.1:1080 -X 5 %h %p";
  programs.ssh.matchBlocks."ft".proxyCommand = "nc -x 127.0.0.1:1080 -X 5 %h %p";

  home.packages = with pkgs; [ ];
}
