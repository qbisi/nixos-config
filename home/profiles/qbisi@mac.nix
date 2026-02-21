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

  home.sessionVariables = rec {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = http_proxy;
  };

  home.packages = with pkgs; [
    paraview
    iproute2mac
    htop
    typst
    (python3.withPackages (
      ps: with ps; [
        numpy
        scipy
        matplotlib
        pytest
        ipykernel
        nanobind
        (fenics-dolfinx.overrideAttrs {
          patches = [ ./nanobind.patch ];
          doInstallCheck = false;
        })
      ]
    ))
  ];

  programs.ssh.matchBlocks = {
    builder = {
      hostname = "192.168.50.189";
    };
    jpzg = {
      user = "ubuntu";
      hostname = "123.56.5.10";
    };
  };

  targets.darwin.copyApps.directory = "Applications";
}
