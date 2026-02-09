# Tmux configuration
{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, config, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.nushell}/bin/nu";
        terminal = "tmux-256color";

        plugins = with pkgs; [
          tmuxPlugins.better-mouse-mode
          tmuxPlugins.gruvbox
          tmuxPlugins.tokyo-night-tmux
          tmuxPlugins.resurrect
          tmuxPlugins.continuum
        ];

        extraConfig = ''
          unbind C-b
          set -sg escape-time 0
          set -g prefix C-Space
          set -g mouse on

          set -g @plugin "janoamaral/tokyo-night-tmux"
          set -g @tokyo-night-tmux_theme night

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

          unbind -n M-j
          unbind -n M-k

          bind -n C-M-j previous-window
          bind -n C-M-k next-window

          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      };

      systemd.user.services.tmux-persistent = {
        Unit = {
          Description = "Persistent tmux session with home-manager config";
          After = [ "graphical-session-pre.target" ];
        };

        Service = {
          Type = "forking";
          ExecStart = "${config.programs.tmux.package}/bin/tmux new-session -d -s main";
          ExecStop = "${config.programs.tmux.package}/bin/tmux kill-session -t main";
          Restart = "on-failure";
          RestartSec = 5;
          Environment = "PATH=${config.home.profileDirectory}/bin:${pkgs.zsh}/bin:/run/current-system/sw/bin";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
