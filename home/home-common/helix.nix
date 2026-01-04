{
  pkgs,
  inputs,
  ...
}:
{
  programs.helix = {
    enable = true;
    # Use helix from flake input for latest features
    package = inputs.helix.packages.${pkgs.system}.default;

    settings = {
      theme = "tokyonight";

      editor = {
        true-color = true;
        color-modes = true;
        lsp.display-messages = true;
      };
    };

    languages = {
      language = [
        {
          name = "rust";
          language-servers = ["rust-analyzer"];
        }
        {
          name = "go";
          language-servers = ["gopls"];
        }
        {
          name = "nix";
          language-servers = ["nil"];
        }
        {
          name = "python";
          language-servers = ["pylsp"];
        }
        {
          name = "javascript";
          language-servers = ["typescript-language-server"];
        }
        {
          name = "typescript";
          language-servers = ["typescript-language-server"];
        }
      ];
    };
  };
}
