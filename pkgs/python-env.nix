{
  lib,
  buildEnv,
  runCommand,
  makeBinaryWrapper,
  python3Packages,
  extraLibs ? [],
}:

let
  inherit (python3Packages) python;
  paths = python3Packages.requiredPythonModules (extraLibs ++ [ python ]) ++ [
    (runCommand "bin" { } ''
      mkdir -p $out/bin
    '')
  ];
  pythonPath = "${placeholder "out"}/${python.sitePackages}";
in
buildEnv {
  name = "python-env";

  inherit paths;

  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    for path in ${lib.concatStringsSep " " paths}; do
      if [ -d "$path/bin" ]; then
        cd "$path/bin"
        for prg in *; do
          if [ -f "$prg" ] && [ -x "$prg" ]; then
            rm -f "$out/bin/$prg"
            if [ "$prg" = "${python.executable}" ]; then
              makeWrapper "${python.interpreter}" "$out/bin/$prg" \
                --inherit-argv0
            elif [ "$(readlink "$prg")" = "${python.executable}" ]; then
              ln -s "${python.executable}" "$out/bin/$prg"
            else
              makeWrapper "$path/bin/$prg" "$out/bin/$prg" \
                --set NIX_PYTHONPATH ${pythonPath}
            fi
          fi
        done
      fi
    done
  '';
}
