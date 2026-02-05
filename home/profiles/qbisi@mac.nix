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
        (fenics-dolfinx.overrideAttrs { doCheck = false; })
      ]
    ))
  ];
}
