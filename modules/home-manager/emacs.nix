# Emacs configuration
{ ... }:
{
  flake.modules.homeManager.emacs =
    { pkgs, ... }:
    {
      programs.emacs = {
        enable = true;
        extraPackages = epkgs: [
          epkgs.dracula-theme
          epkgs.nix-mode
          epkgs.magit
          epkgs.cider
          epkgs.flycheck
          epkgs.flycheck-clojure
        ];

        extraConfig = ''
          (load-theme 'dracula t)

          (setq clojure-indent-style 'always-indent
                clojure-indent-keyword-style 'always-indent
                clojure-enable-indent-specs nil)

          (unless (package-installed-p 'cider)
                  (package-install 'cider))

          (unless (package-installed-p 'clojure-mode)
                  (package-install 'clojure-mode))

          (use-package flycheck
              :ensure t
              :config
              (add-hook 'after-init-hook #'global-flycheck-mode))
        '';
      };
    };
}
