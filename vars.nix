rec {
  user = {
    name = "qbisi";
    authorizedKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc0M/36MG2YkGTPpx7nEc3gILV9VbovrRga1ig1P69b";
    mail = "qbisicwate@gmail.com";
  };
  domain = "qbisi.cc";
  http_proxy = "http://${hosts.e88a.ip}:1080";
  hosts = {
    h88k = {
      ip = "172.16.4.100";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCLBMbos1i4TBM1HlvgiErYE36HcVamVVnG2/2k8Z3b h88k";
      wgpub = "8eVRdLTybPEzCGj9BxlkQlcS68cTrYtib/wH/SGHFkg=";
      wgip = "192.168.200.1";
    };
    e88a = {
      ip = "172.16.5.250";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdVhofWrc/Pxdlnde23tY/xn9ERy8V5p3vyHWm8iLTZ e88a";
      wgpub = "l1tzMK//q/5w+024oTVsdr7rSstm6Z9YX2t/Em5Dexk=";
      wgip = "192.168.200.5";
    };
    x79 = {
      ip = "172.16.5.125";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6hQrT6/2Kmr7dpAHUapxsv2t/uRF+GDehDwekj28mg x79";
      wgpub = "EMzFk0sYdXuQfA8RsM5okGc9Wuxhc75B5vlgClhlSRI=";
      wgip = "192.168.200.2";
    };
    ft = {
      ip = "172.16.7.125";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaB38zfFByF9iolK5iJou7qjCmxtIFWreYMr/dKqeJp ft";
      wgpub = "3LH3eFmP740FxC8ysAYqaR3y+8152TJWb1RaifGDSyc=";
      wgip = "192.168.200.3";
    };
    sl1 = {
      ip = "193.123.224.20";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpyZ8tOF0NzMl5OnM73YL2ppeEcXt5AhbO6lnNloGkf sl1";
      wgpub = "3Lrn9YM3442undduo/i+fZPFWQlLZxOirtaz7N5/WSI=";
      wgip = "192.168.200.101";
    };
    jp1 = {
      ip = "48.210.41.163";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQMKbvA1ruz0RHqqKkGe+oZon05Aiebb7YEf3+8K2Ao jp1";
      wgpub = "2SWxS5Uxpx8n69lzbKF5dIg3jtuDYdAYhmaK0gcZyRc=";
      wgip = "192.168.200.102";
    };
    hk = {
      ip = "20.255.249.53";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0jNkBQ+FGYhjkhbc7n9H2K49fRAZi2x/H0eMnmv91N hk";
      wgpub = "yl5Ita7MiIR3+6dcHVPDiXobqKoxd84jAVVaIchurg0=";
      wgip = "192.168.200.103";
    };
    sg1 = {
      ip = "40.65.160.192";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILU4A9+Zxow+qGt7dEIgsACSQZV+HNEpDgABSjObLD3r sg1";
      wgpub = "IYLI1guFccQETG3Iuhf8ViO7TpWsIG+CsfFSmKbD8zo=";
      wgip = "192.168.200.104";
    };
    sl2 = {
      ip = "132.226.16.187";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvhcDSDHNALzxFEQVHvoxvlXwxdJaciVkhtLZDWCo5U sl2";
      wgpub = "v+hUfovrMpRD6HTtiCs9TFycR+uZtKbA3g1OOp6EZF0=";
      wgip = "192.168.200.105";
    };
    lv = {
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQoF0et/KIteVQAaMeedIHtML36UuFFtGGFDHLyk+1r lv";
      ip = "209.141.53.128";
    };
    ody = {
      ip = "172.16.5.183";
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILG60ATkXJr8v2nIkJRUgR0hzPXbfhSGeRZ3Zybb63O+ ody";
      wgpub = "hpien40f7rgZ7vtcU5Bv3DLBM7nseyZmYKvwfPnonWI=";
      wgip = "192.168.200.4";
    };
    mac = {
      sshpub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsMQ8sngPX9eA1tIZAlcLam41RfeWxyrIS+ozthA0eY mac";
      ip = "172.16.5.113";
    };
  };
}
