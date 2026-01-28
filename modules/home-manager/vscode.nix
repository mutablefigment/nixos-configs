# VSCode configuration
{ ... }:
{
  flake.modules.homeManager.vscode =
    { pkgs, ... }:
    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode.fhs;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          # Development tools
          github.copilot
          github.copilot-chat

          # Language support
          golang.go
          ziglang.vscode-zig
          rust-lang.rust-analyzer
          bbenoist.nix
          jnoortheen.nix-ide
          betterthantomorrow.calva
          ionide.ionide-fsharp
          ms-dotnettools.csharp
          gleam.gleam

          # Themes
          jdinhlife.gruvbox

          # Utilities
          mkhl.direnv
          vadimcn.vscode-lldb
          visualjj.visualjj
          usernamehw.errorlens
        ];

        profiles.default.userSettings = {
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
          "editor.fontLigatures" = true;
          "editor.fontFamily" = "JetBrainsMono Nerd Font Mono";
        };
      };
    };
}
