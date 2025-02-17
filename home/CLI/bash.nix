{
  config,
  pkgs,
  self,
  ...
}:
{
  programs.bash = {
    enable = true;
    sessionVariables = {
      NOSYSABASHRC = 1;
    };
  };
}
