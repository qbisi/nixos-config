{
  autoCmd = [
    # {
    #   event = [ "FileType" ];
    #   command = ":tabnew % | tabprevious | quit | tabnext";
    #   pattern = [ "help" ];
    #   group = "helpBuffer";
    # }
    {
      event = [ "FileType" ];
      command = "only | set buflisted";
      pattern = [ "help" ];
      group = "helpBuffer";
    }
  ];
  autoGroups = {
    helpBuffer = {
      clear = true;
    };
  };
}
