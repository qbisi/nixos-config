{
  config,
  pkgs,
  self,
  ...
}:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
  };
in
{
  home.packages = with pkgs; [
    tex
    times-newer-roman
  ];
}
