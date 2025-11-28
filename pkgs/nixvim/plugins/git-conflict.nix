{
  plugins.git-conflict = {
    enable = true;
    settings = {
      default_commands = true;
      disable_diagnostics = false;
      highlights = {
        current = "DiffText";
        incoming = "DiffAdd";
      };
      list_opener = "copen";
    };
  };
}
