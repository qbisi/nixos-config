{
  opts = {
    keymodel = "startsel,stopsel";
    selection = "exclusive";
  };
  keymaps = [
    {
      mode = [ "n" ];
      key = "<S-up>";
      action = "V<S-up>";
      options = {
        silent = true;
      };
    }
    {
      mode = [ "n" ];
      key = "<S-down>";
      action = "V<S-down>";
      options = {
        silent = true;
      };
    }
    {
      mode = [ "n" ];
      key = "<S-left>";
      action = "v<S-left>";
      options = {
        silent = true;
      };
    }
    {
      mode = [ "n" ];
      key = "<S-right>";
      action = "v<S-right>";
      options = {
        silent = true;
      };
    }
  ];
}
