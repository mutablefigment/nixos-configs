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
      set -sg escape-time 0 # stop the input delay, so vim is usable
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

      # Resize mode - press prefix + r to enter, then use vim keys
      bind r switch-client -T resize-mode
      bind -T resize-mode h resize-pane -L 5 \; switch-client -T resize-mode
      bind -T resize-mode j resize-pane -D 5 \; switch-client -T resize-mode
      bind -T resize-mode k resize-pane -U 5 \; switch-client -T resize-mode
      bind -T resize-mode l resize-pane -R 5 \; switch-client -T resize-mode
      bind -T resize-mode Escape switch-client -T root
      bind -T resize-mode Enter switch-client -T root

      set -g history-limit 10000

      unbind n
      unbind w

      bind n command-prompt "rename-window '%%'"
      bind w new-window -c "#{pane_current_path}"
      
      set -g base-index 1
      set-window-option -g pane-base-index 1

      # Unbind Meta+j and Meta+k
      unbind -n M-j
      unbind -n M-k

      # Window switching with Control + arrow keys
      bind -n C-M-j previous-window
      bind -n C-M-k next-window

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
