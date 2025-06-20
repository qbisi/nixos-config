{
  config,
  pkgs,
  self,
  ...
}:
{
  home.file.".ssh/allowed_signers".text = ''
    qbisicwate@gmail.com namespaces="git" ${self.vars.user.authorizedKeys}
  '';

  programs.git = {
    enable = true;
    userName = self.vars.user.name;
    userEmail = self.vars.user.mail;
    ignores = [
      ".envrc"
      ".direnv"
    ];
    hooks = {
      post-receive = ./post-receive;
    };
    extraConfig = {
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      user.signingkey = "/etc/ssh/authorized_keys.d/qbisi";
      url = {
        "git@github.com" = {
          insteadOf = "github.com";
        };
      };
      # armbian build workaround new limitations imposed by CVE-2022-24765 fix in git,
      # otherwise  "fatal: unsafe repository"
      safe.directory = "/home/${self.vars.user.name}/build";

      receive.denyCurrentBranch = "warn";
    };
  };
}
