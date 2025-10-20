{
  pkgs,
  config,
  ...
}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.gruvbox
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
    ];
    
    extraConfig = ''
      unbind C-b
      set -g prefix C-Space
      set -g mouse on

      # Gruvbox Dark Hard theme
      set -g @gruvbox-theme 'dark-hard'

      unbind v
      unbind h

      unbind %
      unbind '"'

      bind v split-window -h -c "#{pane_current_path}"
      bind h split-window -v -c "#{pane_current_path}"

      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      set -g history-limit 10000

      unbind n
      unbind w

      bind n command-prompt "rename-window '%%'"
      bind w new-window -c "#{pane_current_path}"
      
      set -g base-index 1
      set-window-option -g pane-base-index 1

      bind -n M-j previous-window
      bind -n M-k next-window

      # tmux-resurrect settings
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-capture-pane-contents 'on'

      # tmux-continuum settings
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'
    '';
  };

  # Persistent tmux session via systemd user service
  systemd.user.services.tmux-persistent = {
    Unit = {
      Description = "Persistent tmux session with home-manager config";
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      Type = "forking";
      # Use the home-manager configured tmux
      ExecStart = "${config.programs.tmux.package}/bin/tmux new-session -d -s main";
      ExecStop = "${config.programs.tmux.package}/bin/tmux kill-session -t main";
      Restart = "on-failure";
      RestartSec = 5;
      # Ensure tmux can find the configuration
      Environment = "PATH=${config.home.profileDirectory}/bin:${pkgs.zsh}/bin:/run/current-system/sw/bin";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
