{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    sessionVariables = {
      NOSYSZSHRC = 1;
    };
    initContent = ''
      # custom zsh title in xterm
      DISABLE_AUTO_TITLE="true"
      case $TERM in xterm*)
          precmd () {print -Pn "\e]0;%n@%m: %~\a"}
          ;;
      esac
      # detect vscode editor
      if [ "$VSCODE_INJECTION" = "1" ]; then
        if [[ "$VSCODE_ZDOTDIR" == *"code"* ]]; then
          export EDITOR="code --wait"
        elif [[ "$VSCODE_ZDOTDIR" == *"codium"* ]]; then
          export EDITOR="codium --wait"
          alias code="codium"
        fi
      fi
    '';
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "gentoo";
      plugins = [
        "git"
        "history"
        "wd"
        "sudo"
        "zsh-nix-shell"
      ];
    };
    history = {
      size = 2000;
      save = 2000;
    };
  };
}
