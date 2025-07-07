{
  pkgs,
  ...
}:
{
  programs.helix = {
    enable = true;

    settings = {
      theme = "tokyonight";

      editor = {
        lsp.display-messages = true;
      };

      languages = {
        language-server.typescript-language-server = with pkgs.nodePackages; {
          command = "${typescript-language-server}/bin/typescript-language-server";
          args = [
            "--stdio"
            "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"
          ];
        };

        language = [
          {
            name = "go";
            debugger = {
              command = "dlv";
              name = "devle";
            };
            auto-format = true;
          }
          {
            name = "javascript";
          }
        ];
      };
    };
  };
}
