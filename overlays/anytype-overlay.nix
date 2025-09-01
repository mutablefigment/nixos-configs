# overlays/anytype-overlay.nix
final: prev: {
  anytype = prev.stdenv.mkDerivation rec {
    pname = "anytype";
    version = "latest"; # You can pin this to a specific tag later

    src = prev.fetchFromGitHub {
      owner = "anyproto";
      repo = "anytype-ts";
      rev = "main"; # Use "main" for latest commit or a specific tag
      hash = ""; # Leave empty initially, nix will tell you the correct hash
    };

    nativeBuildInputs = with prev; [
      nodejs_20
      yarn
      python3
      pkg-config
      cairo
      pango
    ];

    buildInputs = with prev; [
      gtk3
      glib
      alsa-lib
      libxkbcommon
      libsecret
      gsettings-desktop-schemas
    ];

    buildPhase = ''
      yarn install --frozen-lockfile
      yarn build
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -r dist/linux-unpacked $out/lib/anytype
      ln -s $out/lib/anytype/anytype $out/bin/anytype
    '';
  };
}
