{
  stdenv,
  fetchurl,
  pkg-config,
  ell,
  ...
}:
stdenv.mkDerivation rec {
  pname = "mptcpd";
  version = "0.12";

  src = fetchurl {
    url = "https://github.com/multipath-tcp/mptcpd/releases/download/v${version}/mptcpd-${version}.tar.gz";
    hash = "sha256-BQfUlzg7dzoWjNNfRoC0GJT82NlBy2YZgAqOK+2DHL4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ ell ];

}
