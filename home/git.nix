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

  # programs.git-credential-oauth.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      ".envrc"
      ".direnv"
    ];
    hooks = {
      post-receive = pkgs.writeShellScript "post-receive" ''
        export GIT_WORK_TREE=..
        git checkout -f HEAD

        repo_dir=$(git rev-parse --show-toplevel)
        repo_name=$(basename "$repo_dir")
      '';
    };
    settings = {
      user = {
        name = self.vars.user.name;
        email = self.vars.user.mail;
        signingkey = "/etc/ssh/authorized_keys.d/qbisi";
      };
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };
      url = {
        "git@ssh.github.com" = {
          insteadOf = "git@github.com";
        };
      };
      sendemail = {
        smtpEncryption = "tls";
        smtpServer = "smtp.gmail.com";
        smtpUser = "qbisicwate";
        smtpServerPort = 587;
        suppresscc = "self";
      };

      # armbian build workaround new limitations imposed by CVE-2022-24765 fix in git,
      # otherwise  "fatal: unsafe repository"
      # safe.directory = [
      #   "${config.home.homeDirectory}/build"
      #   "${config.home.homeDirectory}/build/*"
      # ];

      receive.denyCurrentBranch = "warn";
    };
  };
}
