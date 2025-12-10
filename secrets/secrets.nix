let
  qbisi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc0M/36MG2YkGTPpx7nEc3gILV9VbovrRga1ig1P69b qbisi";
  ody = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILG60ATkXJr8v2nIkJRUgR0hzPXbfhSGeRZ3Zybb63O+ ody";
  h88k = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCLBMbos1i4TBM1HlvgiErYE36HcVamVVnG2/2k8Z3b h88k";
  sw799 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ47CjM3qFP+hsDR+A2dyeUglPQWv9xU41Dhht5Ih8vM sw799";
  x79 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6hQrT6/2Kmr7dpAHUapxsv2t/uRF+GDehDwekj28mg x79";
  ft = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaB38zfFByF9iolK5iJou7qjCmxtIFWreYMr/dKqeJp ft";
  sl1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpyZ8tOF0NzMl5OnM73YL2ppeEcXt5AhbO6lnNloGkf sl1";
  hk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0jNkBQ+FGYhjkhbc7n9H2K49fRAZi2x/H0eMnmv91N hk";
  sg1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILU4A9+Zxow+qGt7dEIgsACSQZV+HNEpDgABSjObLD3r sg1";
  jp1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQMKbvA1ruz0RHqqKkGe+oZon05Aiebb7YEf3+8K2Ao jp1";
  sl2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvhcDSDHNALzxFEQVHvoxvlXwxdJaciVkhtLZDWCo5U sl2";
  e88a = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdVhofWrc/Pxdlnde23tY/xn9ERy8V5p3vyHWm8iLTZ e88a";
  devKeys = [
    ody
    h88k
    x79
    ft
    sl2
    e88a
    sw799
  ];
  vpsKeys = [
    sl1
    jp1
    hk
    sg1
  ];
  allKeys = devKeys ++ vpsKeys;
  secrets = {
    "qbisi/google-client.age".publicKeys = [ ];
    "qbisi/google-api.age".publicKeys = [ ];
    "qbisi/passwd.age".publicKeys = allKeys;
    "acme/acme.age".publicKeys = devKeys;
    "root/ddclient.age".publicKeys = devKeys;
    "sing-box/sing-uuid.age".publicKeys = devKeys;
    "sing-box/sing-key.age".publicKeys = devKeys;
    "sing-box/sing-pubkey.age".publicKeys = devKeys;
    "sing-box/sing-wgcf.age".publicKeys = devKeys;
    "hydra-queue-runner/hydra_ed25519.age".publicKeys = devKeys;
    "root/id_ed25519.age".publicKeys = devKeys;
    "root/cachix.age".publicKeys = devKeys;
    "root/github.age".publicKeys = devKeys;
    "alist/jwt.age".publicKeys = allKeys;
    "atticd/token.age".publicKeys = [ sl2 ];
    "root/wg-h88k.age".publicKeys = [ h88k ];
    "root/wg-ody.age".publicKeys = [ ody ];
    "root/wg-x79.age".publicKeys = [ x79 ];
    "root/wg-ft.age".publicKeys = [ ft ];
    "root/wg-sl1.age".publicKeys = [ sl1 ];
    "root/wg-jp1.age".publicKeys = [ jp1 ];
    "root/wg-hk.age".publicKeys = [ hk ];
    "root/wg-sg1.age".publicKeys = [ sg1 ];
    "root/wg-sl2.age".publicKeys = [ sl2 ];
    "root/wg-e88a.age".publicKeys = [ e88a ];
    "harmonia/harmonia-sl2.age".publicKeys = [ sl2 ];
    "harmonia/harmonia-x79.age".publicKeys = [ x79 ];
  };
in
builtins.mapAttrs (name: value: { publicKeys = value.publicKeys ++ [ qbisi ]; }) secrets
