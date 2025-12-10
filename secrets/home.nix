{
  lib,
  pkgs,
  config,
  inputs,
  self,
  ...
}:
let
  ages = (lib.filesystem.listFilesRecursive ./.);
  keynames = map (p: lib.removePrefix (toString ./. + "/") (toString p)) ages;
  keymaps = import ./secrets.nix;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age.secrets =
    let
      filter =
        keyname:
        (lib.any (key: lib.hasSuffix " ${config.home.username}" key)
          keymaps."${keyname}".publicKeys or [ ]
        );
      filterdNames = lib.filter filter keynames;
    in
    lib.listToAttrs (map (keyname: {
      name = lib.removeSuffix  ".age" (baseNameOf keyname);
      value = {
        file = ./. + "/${keyname}";
      };
    }) filterdNames);
}
