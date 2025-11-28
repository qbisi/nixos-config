{
  plugins.bufferline = {
    enable = true;
    settings.options = {
      alwaysShowBufferline = false;
      show_close_icons = false;
      show_buffer_close_icons = false;
      offsets = [
        {
          filetype = "neo-tree";
          text = "Neo-Tree";
          separator = true;
          text_align = "left";
        }
      ];
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>bp";
      action = "<CMD>BufferLineTogglePin<CR>";
      options.desc = "Toggle Pin";
    }
    {
      mode = "n";
      key = "<leader>bP";
      action = "<CMD>BufferLineGroupClose ungrouped<CR>";
      options.desc = "Delete Non-Pinned Buffers";
    }
    {
      mode = "n";
      key = "<leader>bo";
      action = "<CMD>BufferLineCloseOthers<CR>";
      options.desc = "Delete Other Buffers";
    }
  ];
}
