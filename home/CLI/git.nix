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
    ignores = [
      ".envrc"
      ".direnv"
    ];
    extraConfig = {
      url = {
        "git@github.com" = {
          insteadOf = "github.com";
        };
      };
      # armbian build workaround new limitations imposed by CVE-2022-24765 fix in git,
      # otherwise  "fatal: unsafe repository"
      # safe.directory = "/home/${self.vars.user.name}/build";
    };
  };
}
