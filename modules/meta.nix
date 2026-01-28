# Top-level metadata options used across the flake
{ lib, ... }:
{
  options.meta = {
    owner = {
      username = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "anon";
      };
      email = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "";
      };
    };
    sshKeysPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to SSH public keys file";
    };
  };
}
