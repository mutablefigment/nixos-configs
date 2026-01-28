# Imports flake-parts modules extension for storing lower-level modules
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
