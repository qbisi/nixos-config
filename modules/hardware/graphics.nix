{
  lib,
  config,
  pkgs,
  ...
}:
{
  # Fixup for opengl not found sshing from non-nixos system
  hardware.graphics.extraPackages = lib.mkIf (config.hardware.graphics.enable) [
    (pkgs.runCommand "mesa_glxindirect" { } (''
      mkdir -p $out/lib
      ln -s ${pkgs.mesa}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
    ''))
  ];
}
