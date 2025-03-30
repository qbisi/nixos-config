{
  boot.kernel.sysctl = {
    "kernel.panic" = 60;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
    "net.core.rmem_max" = 7500000;
    "net.core.wmem_max" = 7500000;
  };
}
