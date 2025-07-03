{
  pkgs,
  ...
}:
{

  home.file.".zed_server".source = "${pkgs.zed-editor.remote_server}/bin";

  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;

    userSettings = {
      features = {
        copilot = true;
      };
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
      vim_mode = false;
      ui_font_size = 16;
      buffer_font_size = 16;
      theme = {
        mode = "dark";
        dark = "Tokyo Night";
      };
    };

    extensions = [
      "nix"
      "toml"
      "elixir"
      "make"
      "go"
      "zig"
    ];
  };
}
