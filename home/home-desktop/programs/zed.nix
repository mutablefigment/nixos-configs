{
  pkgs,
  lib,
  ...
}:
{

  home.file.".zed_server".source = "${pkgs.zed-editor.remote_server}/bin";

  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;
    package = pkgs.zed-editor-fhs;

    extensions = [
      "nix"
      "toml"
      "elixir"
      "make"
      "go"
      "zig"
      "PHP"
      "golangci-lint"
    ];

    userSettings = {
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
      helix_mode = true;
      theme = "Gruvbox Dark Hard";
      load_direnv = "shell_hook";
      dap = {
        CodeLLDB = {
          binary = lib.getExe' pkgs.lldb_21 "lldb-dap";
        };
        # Delve = {
          # binary = lib.getExe' pkgs.delve "dlv-dap";
        # };
      };
    };
  };
}
