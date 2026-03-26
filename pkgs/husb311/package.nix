{
  lib,
  stdenv,
  linux,
}:

stdenv.mkDerivation {
  pname = "tcpci-husb311";
  version = "0-unstable-2026-03-26";

  src = ./src;

  makeFlags = [
    "KERNEL_DIR=${lib.getDev linux}/lib/modules/${linux.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    install -D tcpci_husb311.ko \
      $out/lib/modules/${linux.modDirVersion}/kernel/drivers/usb/typec/tcpm/tcpci_husb311.ko

    runHook postInstall
  '';

  meta = {
    description = "Out-of-tree Hynetek HUSB311 TCPCI driver kernel module";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ qbisi ];
  };
}
