{
  lib,
  stdenv,
  fetchFromGitLab,

  cmake,
  kdePackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-phonebook";
  version = "24.02.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "plasma-phonebook";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1fTJrcI78P7vxCercC83iCCTzVgZUzKsopAlHH1WIts=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    kcontacts
    kcoreaddons
    kirigami
    kirigami-addons
    kpeople
  ];

  meta = with lib; {
    description = "Phone book for Plasma Mobile";
    mainProgram = "plasma-phonebook";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-phonebook";
    # https://invent.kde.org/plasma-mobile/plasma-phonebook/-/commit/3ac27760417e51c051c5dd44155c3f42dd000e4f
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kurnevsky ];
  };
})
