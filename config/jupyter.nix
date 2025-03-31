{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [ 8000 ];

  systemd.services.jupyterhub = {
    serviceConfig = {
      CacheDirectory = "jupyterhub";
    };
  };

  services.jupyterhub = {
    enable = true;
    host = "0.0.0.0";
    port = 8000;
    authentication = "jupyterhub.auth.PAMAuthenticator";
    extraConfig = ''
      c.Authenticator.allowed_users = {'${config.users.users.admin.name}'}
      c.Authenticator.admin_users = {'${config.users.users.admin.name}'}
    '';
    kernels = {
      firedrake =
        let
          env = pkgs.pkgs-fem.python312.withPackages (
            ps: with ps; [
              firedrake
              matplotlib
              ipykernel
              ipympl
            ]
          );
        in
        {
          displayName = "firedrake";
          argv = [
            "${env.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          env = {
            OMP_NUM_THREADS = "1";
            VIRTUAL_ENV = "$HOME";
            SHELL = "${pkgs.bash}/bin/bash";
            PATH = "$PATH:${lib.getBin pkgs.glibc}/bin:${env}/bin";
          };
          language = "python";
        };
    };
  };
}
