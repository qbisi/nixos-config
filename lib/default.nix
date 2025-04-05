{
  self,
  inputs,
  lib,
  ...
}:
{
  flake = {
    lib = rec {
      genAttrs' = items: v: lib.listToAttrs (map (item: lib.nameValuePair item.name (v item)) items);

      cartesianProduct' =
        attrs: lib.cartesianProduct (lib.mapAttrs ((name: value: lib.toList value)) attrs);

      genTag =
        list: args: (lib.concatStringsSep "-" (lib.remove "" (lib.forEach list (x: args.${x} or ""))));

      isPrivateIP =
        ip:
        lib.any (prefix: lib.hasPrefix prefix ip) [
          "10."
          "172.16."
          "192.168."
          "127."
        ];
      
      listNixFilesRecursive = dir: lib.filter (p: lib.hasSuffix ".nix" p) (lib.filesystem.listFilesRecursive dir);
    };
  };
}
