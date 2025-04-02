{
  systemd.network.wait-online = {
    timeout = 30;
    ignoredInterfaces = [
      "wg0"
      "tun0"
    ];
    anyInterface = true;
  };
}
