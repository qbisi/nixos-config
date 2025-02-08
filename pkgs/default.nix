{
  perSystem =
    {
      config,
      pkgs,
      lib,
      system,
      inputs',
      ...
    }:
    {
      legacyPackages =
        (import ./top-level.nix { inherit pkgs; }) // inputs'.nixos-images.legacyPackages;
    };
}
