{
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      plenary-nvim
      gruvbox-material
      mini-nvim
      nvim-tree-lua
      {
        plugin = vim-startify;
        config = "let g:startify_change_to_vcs_root = 0";
      }
    ];


    extraConfig = ''
      set number relativenumber
      set tabstop=2
    '';
  };
}