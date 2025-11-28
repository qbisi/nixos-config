{ makeNixvim, nixfmt-rfc-style }:
makeNixvim {
  imports = [
    ./plugins
    ./keymaps.nix
    ./select.nix
    ./autocmd.nix
  ];

  globals.mapleader = " ";

  # Color scheme.
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      transparent_background = true;
      flavour = "macchiato";
      integrations = {
        cmp = true;
        gitsigns = true;
        mini = {
          enabled = true;
          indentscope_color = "";
        };
        notify = false;
        nvimtree = true;
        treesitter = true;
      };
    };
  };

  # Options.
  opts = {
    # Indent settings.
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    # Line number.
    number = true;
    # relativenumber = true;
    signcolumn = "yes";
    # Search case sensitivity.
    ic = true;
    # Keymodel.
    virtualedit = "onemore";
    # Allow move across lines.
    whichwrap = "b,s,h,l,<,>";
    # Complete first full match, next match, etc.
    wildmode = "longest,list";

  };

  extraConfigLua = ''
    if vim.env.SSH_TTY then
        vim.opt.clipboard = ""
    else
        vim.opt.clipboard = "unnamedplus"
    end
  '';

  # Clipboard.
  clipboard = {
    providers.xclip.enable = true;
    providers.wl-copy.enable = true;
  };

  # Packages
  extraPackages = [
    nixfmt-rfc-style
  ];

}
