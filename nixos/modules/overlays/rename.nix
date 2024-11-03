{ lib, ... }:
let
  inherit (lib)
    mkRemovedOptionModule
    ;
in
{
  imports = [
    # (mkRemovedOptionModule ["networking" "nat" "externalInterface"] "Use networking.nat.externalInterfaces instead.")
  ];
}
