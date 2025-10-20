{
  pkgs,
  ...
}:
let
  # Extensions not in nixpkgs
  vscode-dance = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "dance";
      publisher = "gregoire";
      version = "0.5.19";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };

  vscode-dance-helix = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "dance-helix";
      publisher = "gregoire";
      version = "0.1.3";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };
in
{

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Development tools
      github.copilot
      github.copilot-chat
      # ms-python.python

      # Language support
      golang.go
      ziglang.vscode-zig
      rust-lang.rust-analyzer
      bbenoist.nix
      jnoortheen.nix-ide
      betterthantomorrow.calva
      ionide.ionide-fsharp
      ms-dotnettools.csharp

      # Themes
      enkia.tokyo-night
      jdinhlife.gruvbox
      arcticicestudio.nord-visual-studio-code

      # Utilities
      mkhl.direnv
      vadimcn.vscode-lldb
    ] ++ [
      # Modal editing (Dance with Helix keybindings)
      vscode-dance
      vscode-dance-helix
    ];

    userSettings = {
      "telemetry.editStats.enabled" = false;
      "telemetry.feedback.enabled" = false;
      "telemetry.telemetryLevel" = "off";
      "calva.telemetryEnabled" = false;
      "containers.containerClient" = "com.microsoft.visualstudio.containers.docker";
      "containers.orchestratorClient" = "com.microsoft.visualstudio.orchestrators.dockercompose";
      "git.autofetch" = true;
      "workbench.colorTheme" = "Gruvbox Dark Hard";
      "chat.tools.terminal.autoApprove" = {
        "go" = true;
        "stdlib\\" = true;
        "init\"" = true;
      };
      "zig.zls.enabled" = "on";
      "github.copilot.enable" = {
        "*" = false;
        "plaintext" = false;
        "markdown" = false;
        "scminput" = false;
      };
      "intelliphp.inlineSuggestionsEnabled" = false;
      "php.codeActions.enabled" = false;
      "editor.wordBasedSuggestions" = "off";
    };
  };
}
