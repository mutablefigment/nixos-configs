{
  pkgs,
  ...
}: {

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhs;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # {
      #   name = "code-d";
      #   publisher = "webfreak";
      #   version = "0.23.2";
      #   sha256 = "sha256-v/Dck4gE9kRkfIWPAkUmPqewyTVVKrBgAjpNuCROClE=";
      # }
      {
        name = "vscode-test-explorer";
        publisher = "hbenl";
        version = "2.21.1";
        sha256 = "sha256-fHyePd8fYPt7zPHBGiVmd8fRx+IM3/cSBCyiI/C0VAg=";
      }
      {
        name = "test-adapter-converter";
        publisher = "ms-vscode";
        version = "0.1.8";
        sha256 = "sha256-ybb3Wud6MSVWEup9yNN4Y4f5lJRCL3kyrGbxB8SphDs=";
      }
      {
        name = "Nix";
        publisher = "bbenoist";
        version = "1.0.1";
        sha256 = "sha256-qwxqOGublQeVP2qrLF94ndX/Be9oZOn+ZMCFX1yyoH0=";
      }
      {
        name = "typst-lsp";
        publisher = "nvarner";
        version = "0.11.0";
        sha256 = "sha256-fs+CBg3FwzTn608dm9EvfF2UrI2Sa5hsm0OK/WQyy6o=";
      }
    ];
  };

  # home.packages = with pkgs; [
  #   typst
  #   typst-lsp
  # ];  
}
