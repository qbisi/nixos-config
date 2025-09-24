{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "tcping";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "pouriyajamshidi";
    repo = "tcping";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-1E5c3TYMdPyDQYZ7pu6S+RTAG2q/86sPdvR1H2FSKy8=";
  };

  vendorHash = "sha256-YgJZB7RkgNavxSgbfzGpLMWjztOeOieMwh2BBVMcprA=";

  meta = {
    description = "Cross-platform ping program using TCP instead of ICMP, inspired by Linux's ping utility";
    homepage = "https://github.com/pouriyajamshidi/tcping";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
    mainProgram = "tcping";
  };
})
