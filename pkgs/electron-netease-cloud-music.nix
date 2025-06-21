{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarn,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "electron-netease-cloud-music";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "Rocket1184";
    repo = "electron-netease-cloud-music";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DgrBtKOC3pCgr032LparioQKP19gBgUC/1GdnsHtr0I=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-avLIe0EM/9G6lU7POYlqHyNpfaN1NPn7lmrNL1Fjj9Q=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  preBuild = ''
    NODE_OPTIONS=--openssl-legacy-provider yarn --offline dist
  '';

  yarnBuildFlags = stdenv.hostPlatform.parsed.kernel.name;

  installPhase = ''
    mkdir -p $out
  '';

  meta = {
    description = "UNOFFICIAL client for music.163.com";
    homepage = "https://github.com/Rocket1184/electron-netease-cloud-music";
    changelog = "https://github.com/Rocket1184/electron-netease-cloud-music/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = with lib.maintainers; [ qbisi ];
    broken = true;
  };
})
