{
  stdenvNoCC,
  lib,
  fetchurl,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "v2ray-rules-dat";
  version = "202507252214";

  src1 = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${finalAttrs.version}/geoip.dat";
    hash = "sha256-yugV6mgj6JLhVmaYO16667Bu6kttvKk1OEbs2PvEHDQ=";
  };
  src2 = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${finalAttrs.version}/geosite.dat";
    hash = "sha256-XEgYbH2k/S9xWnlYFe+oTQ9zQqIY4QHL0EhNGr2T6aw=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src1 $out/share/v2ray/geoip.dat
    install -Dm644 $src2 $out/share/v2ray/geosite.dat

    runHook postInstall
  '';

  dontFixup = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Enhanced edition of V2Ray rules dat files";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
