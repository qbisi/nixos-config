{
  # windows-like
  keymaps = [
    {
      mode = [
        "n"
        "v"
      ];
      key = "<C-F>";
      action = "*''";
      options = {
        desc = "Find select";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<C-H>";
      action = "cgn";
      options = {
        desc = "Replace";
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<C-A>";
      action = "<ESC>ggVG";
      options = {
        desc = "Select All";
      };
    }
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<C-z>";
      action = "<cmd>undo<CR>";
      options = {
        desc = "Undo";
      };
    }
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<C-y>";
      action = "<cmd>redo<CR>";
      options = {
        desc = "Redo";
      };
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-s>";
      action = "<Esc>:update|checktime<CR>";
      options = {
        desc = "Save";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<C-n>";
      action.__raw = ''
        function()
          vim.cmd("enew") -- Create a new empty buffer
          local filename = vim.fn.input("Save as: ", "", "file")
          if filename ~= "" then
            vim.cmd("write " .. filename)
          else
            print("No filename entered. Buffer not saved.")
          end
        end
      '';
    }
    # copy/cut to clipboard
    {
      mode = [ "v" ];
      key = "<C-c>";
      action = ''"+y'';
    }
    {
      mode = [ "v" ];
      key = "<C-x>";
      action = ''"*d'';
    }
    # cursor move
    {
      mode = [ "n" ];
      key = "<C-up>";
      action = "3k";
    }
    {
      mode = [ "n" ];
      key = "<C-down>";
      action = "3j";
    }
    # formatter
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<M-S-f>";
      action.__raw = ''
        function()
          vim.lsp.buf.format()
        end
      '';
    }
    # Window movement.
    {
      mode = [ "n" ];
      key = "<M-left>";
      action = "<c-w>h";
    }
    {
      mode = [ "n" ];
      key = "<M-down>";
      action = "<c-w>j";
    }
    {
      mode = [ "n" ];
      key = "<M-up>";
      action = "<c-w>k";
    }
    {
      mode = [ "n" ];
      key = "<M-right>";
      action = "<c-w>l";
    }
    {
      mode = [ "n" ];
      key = "<leader>w";
      action = "<c-w>";
      options = {
        noremap = true;
        desc = "window";
      };
    }
    # Tab movement
    {
      mode = [ "n" ];
      key = "<M-0>";
      action = "<cmd>tabclose<cr>";
    }
    {
      mode = [ "n" ];
      key = "<M-4>";
      action = "4gt";
    }
    {
      mode = [ "n" ];
      key = "<M-3>";
      action = "3gt";
    }
    {
      mode = [ "n" ];
      key = "<M-2>";
      action = "2gt";
    }
    {
      mode = [ "n" ];
      key = "<M-1>";
      action = "1gt";
    }
    # Buffer movement
    {
      mode = [ "n" ];
      key = "<S-Tab>";
      action = "<cmd>bprevious<cr>";
      options = {
        desc = "Previous Buffer";
      };
    }
    {
      mode = [ "n" ];
      key = "<Tab>";
      action = "<cmd>bnext<cr>";
      options = {
        desc = "Next Buffer";
      };
    }
    # Misc
    {
      mode = [ "n" ];
      key = "<leader>qq";
      action = "<cmd>qa!<cr>";
      options = {
        desc = "Quit All";
      };
    }
    {
      mode = [ "n" ];
      key = "<leader>hh";
      action = "<cmd>nohlsearch<cr>";
      options = {
        desc = "Clear Search Highlight";
      };
    }
  ];
}
