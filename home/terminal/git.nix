{
  config,
  pkgs,
  self,
  ...
}:
{
  programs.git = {
    enable = true;
    userName = self.vars.user.name;
    userEmail = self.vars.user.mail;
    extraConfig = {
      url = {
        "git@github.com" = {
          insteadOf = "github.com";
        };
      };
    };
  };
}
