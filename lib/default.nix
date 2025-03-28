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

      cartesianProduct' = attrs: lib.cartesianProduct (lib.mapAttrs ((name: value: lib.toList value)) attrs);

      genTag = list: args: (lib.concatStringsSep "-" (lib.remove "" (lib.forEach list (x: args.${x} or ""))));
    };
  };
}
