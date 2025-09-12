# overlays/anytype-overlay.nix
final: prev:
{
  anytype = prev.anytype.overrideAttrs (old: rec {
    pname = "anytype";
    version = "0.49.2";
    name = "${pname}-${version}";  # Force a new derivation name
    
    src = final.fetchFromGitHub {
      owner = "anyproto";
      repo = "anytype-ts";
      tag = "v${version}";
      hash = "sha256-8+x2FmyR5x9Zrm3t71RSyxAKcJCvnR98+fqHXjBE7aU=";
    };
    
    # Update npm dependencies hash for new version - use fake hash to force recalculation
    npmDepsHash = final.lib.fakeHash;
    
    # Update locales to a more recent commit compatible with v0.49.2
    locales = final.fetchFromGitHub {
      owner = "anyproto";
      repo = "l10n-anytype-ts";
      rev = "920d371ca1e835bc62860693dfad5f1e7ac83373";
      hash = "sha256-1Ir2uh3b7Fp8N1Nj9G+n9YcROjYq3oedski1zq3lv5A=";
    };
    
    # Remove patches that don't apply to v0.49.2
    patches = [];
    
    # Clear any npmFlags that might interfere
    npmFlags = old.npmFlags or [];
  });
}
