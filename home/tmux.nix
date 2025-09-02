{ config, pkgs, ... }:
{
  programs.tmux = {
    shortcut = "a";
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    # escapeTime = 0;
    # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];

    extraConfig = ''
      set -g status off
      set -g set-titles on
      set -g set-titles-string "#{USER}@#H:#{PWD}"

      # Mouse works as expected
      set-option -g mouse on
      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
