{ lib, ... }:
{
  plugins.mini = {
    enable = true;
    modules = {
      comment = {
        mappings = {
          comment = "<C-_>";
          comment_line = "<C-_>";
          comment_visual = "<C-_>";
          textobject = "<C-_>";
        };
    };
      move = {
        mappings = {
          # Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          left = "<M-left>";
          right = "<M-right>";
          down = "<M-down>";
          up = "<M-up>";

          # Move current line in Normal mode
          line_left = "<S-M-left>";
          line_right = "<S-M-right>";
          line_down = "<S-M-down>";
          line_up = "<S-M-up>";
        };

        options = {
          # Automatically reindent selection during linewise vertical move
          reindent_linewise = false;
        };
      };
    };
  };
  keymaps = [
    {
      mode = [ "n" ];
      key = "<c-w><c-w>";
      action = lib.nixvim.mkRaw ''
        function()
        	local bd = require("mini.bufremove").delete
        	if vim.bo.modified then
        		local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
        		if choice == 1 then -- Yes
        			vim.cmd.write()
        			bd(0)
        		elseif choice == 2 then -- No
        			bd(0, true)
        		end
        	else
        		bd(0)
        	end
        end
      '';
      options = {
        desc = "Remove Buffere";
      };
    }
  ];
}
