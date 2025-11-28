{
  plugins.toggleterm = {
    enable = true;
    settings = {
      direction = "float";
      float_opts = {
        border = "curved";
      };
      # size = ''
      #   function()
      #       return vim.o.lines * 0.8
      #   end
      # '';
      # open_mapping = "[[<c-\\>]]";
    };
  };

  keymaps = [
    {
      mode = [
        "n"
        "t"
      ];
      key = "<c-\\>";
      action = "<cmd>ToggleTerm<cr>";
      options = {
        desc = "Toggle Terminal";
      };
    }
  ];
}
