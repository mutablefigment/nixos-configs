# Development shell for the flake
{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          inputs.colmena.packages.${system}.colmena
        ];
      };
    };
}
