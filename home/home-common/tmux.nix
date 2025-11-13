{
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.nord
    ];
    
    extraConfig = ''
      unbind C-b
      unbind Esc
      set -g prefix C-Space
      set -g mouse on
      set -g @plugin "arcticicestudio/nord-tmux"

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
    '';
  };
}
