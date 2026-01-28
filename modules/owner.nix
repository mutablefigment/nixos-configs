# Set owner metadata from inputs
{ inputs, ... }:
{
  meta = {
    owner.username = "anon";
    sshKeysPath = inputs.ssh-keys.outPath;
  };
}
