{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    sessionVariables = {
      NOSYSZSHRC = 1;
    };
    initExtra = ''
      # custom zsh title in xterm
      DISABLE_AUTO_TITLE="true" 
      case $TERM in xterm*)
          precmd () {print -Pn "\e]0;%n@%m: %~\a"}
          ;;
      esac
      # detect vscode editor
      if [ "$VSCODE_INJECTION" = "1" ]; then
          export EDITOR="code --wait"
      fi
    '';
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      help = "run-help";
      code = "codium";
    };
    oh-my-zsh = {
      enable = true;
      theme = "gentoo";
      plugins = [
        "git"
        "history"
        "wd"
        "sudo"
      ];
    };
    history = {
      size = 2000;
      save = 2000;
    };
  };
}
