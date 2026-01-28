# Shell configuration (zsh, fish, nushell, etc.)
{ inputs, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = true;
        };
      };

      programs.nushell = {
        enable = true;
        environmentVariables = {
          SSH_AUTH_SOCK = "/home/anon/.1password/agent.sock";
        };
      };

      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };

      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      programs.broot.enable = true;
      programs.fish.enable = true;
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        oh-my-zsh.enable = true;

        shellAliases = {
          "tm" = "tmux attach -t main || tmux new-session -s main";
          "tma" = "tmux attach -t main";
          "tmd" = "tmux detach";
          "tml" = "tmux list-sessions";
        };

        plugins = [
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.8.0";
              sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
            };
          }
        ];
      };
    };
}
