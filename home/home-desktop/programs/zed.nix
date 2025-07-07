{
  pkgs,
  ...
}: {

  home.file.".zed_server".source = "${pkgs.zed-editor.remote_server}/bin";

  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;

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
      vim_mode = false;
      theme = "Tokyo Night";
    };
  };
}
