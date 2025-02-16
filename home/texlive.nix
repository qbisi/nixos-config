{
  config,
  pkgs,
  self,
  ...
}:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-medium;
  };
in
{
  home.packages = with pkgs; [
    tex
    # Microsoft's TrueType core fonts for the Web
    corefonts
];

  fonts.fontconfig.enable = true;
}
