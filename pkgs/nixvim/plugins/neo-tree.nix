{
  plugins.neo-tree = {
    enable = true;
    settings = {
      auto_clean_after_session_restore = true;
      close_if_last_window = false;
      # buffers.follow_current_file.enabled = true;
      filesystem = {
        filtered_items = {
          visible = true;
          always_show = [ ".gitignore" ];
          never_show = [
            ".DS_Store"
            "thumbs.db"
          ];
        };
        hijack_netrw_behavior = "disabled";
        use_libuv_file_watcher = true;
      };
      window = {
        position = "left";
        mappings = {
          "<left>".__raw = ''
            function(state)
              local node = state.tree:get_node()
              if node.type == "directory" and node:is_expanded() then
                require("neo-tree.sources.filesystem").toggle_directory(state, node)
              else
                require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
              end
            end
          '';
          "<right>".__raw = ''
            function(state)
              local node = state.tree:get_node()
              if node.type == "directory" then
                if not node:is_expanded() then
                  require("neo-tree.sources.filesystem").toggle_directory(state, node)
                elseif node:has_children() then
                  require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
                end
              else
                require("neo-tree.sources.common.preview").show(state)
              end
            end
          '';
        };
      };
    };
  };
  keymaps = [
    {
      mode = [ "n" ];
      key = "<leader>e";
      action = "<cmd>Neotree toggle reveal<CR>";
      options = {
        desc = "Toggle Neo-Tree";
      };
    }
  ];
}
