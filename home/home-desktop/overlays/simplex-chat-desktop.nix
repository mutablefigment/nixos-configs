final: prev:
{
    simplex-chat-desktop = prev.simplex-chat-desktop.overrideAttrs (old: {
        version = "5.4.0";
        
        src = prev.fetchurl {
            url = "https://github.com/simplex-chat/simplex-chat/releases/download/v${version}/simplex-desktop-x86_64.AppImage";
            hash = "sha256-vykdi7SXKKsjYE/yixGrKQoWuUIOAjofLUn/fsdmLMc=";
        };
    });
}