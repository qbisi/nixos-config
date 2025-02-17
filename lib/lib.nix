{
  self,
  inputs,
  lib,
  ...
}:
with lib;
rec {
  genAttrs' = items: v: listToAttrs (map (item: nameValuePair item.name (v item)) items);

  listNixFile =
    path: with builtins; filter (name: match "(.+)\\.nix" name != null) (attrNames (readDir path));

  nixBaseNameOf = path: toString path |> baseNameOf |> removeSuffix ".nix" ;

  listNixName = path: with builtins; map (file: head (match "(.+)\\.nix" file)) (listNixFile path);

  cartesianProduct' = attrs: cartesianProduct (mapAttrs ((name: value: toList value)) attrs);

  genTag = list: args: (concatStringsSep "-" (remove "" (forEach list (x: args.${x} or ""))));

  listNixFileRecursive =
    d: builtins.filter (path: match "(.+)\\.nix" (toString path) != null) (filesystem.listFilesRecursive d);
}
