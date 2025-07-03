{
  pkgs,
  ...
}:
{

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      github.copilot
      github.copilot-chat
      ms-python.python
      golang.go
      ziglang.vscode-zig
      enkia.tokyo-night
      bbenoist.nix
      betterthantomorrow.calva
      mkhl.direnv
    ];
  };
}
