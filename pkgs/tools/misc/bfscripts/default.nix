{ stdenv
, fetchFromGitHub
, lib
, efibootmgr
, dracut
, makeWrapper
, python3
}:

let
  binaries = [
    "mlx-mkbfb"
  ];
in
stdenv.mkDerivation rec {
  pname = "bfscripts";
  version = "unstable-2023-05-15";

  src = fetchFromGitHub {
    owner = "Mellanox";
    repo = pname;
    rev = "1da79f3ece7cdf99b2571c00e8b14d2e112504a4";
    hash = "sha256-pTubrnZKEFmtAj/omycFYeYwrCog39zBDEszoCrsQNQ=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    python3
  ];

  installPhase = ''
    for file in ${toString (map (b: if b ? "name" then b.name else b) binaries)}; do
      install -D $file $out/bin/$file
    done
  '';

  preFixup = ''
    ${lib.concatLines (builtins.map (binary:
      "wrapProgram $out/bin/${binary.name} --prefix ${ lib.makeBinPath binary.deps }"
    ) (lib.filter lib.isAttrs binaries))}
  '';

  meta = with lib;
    {
      description = "Collection of scripts used for BlueField SoC system management";
      homepage = "https://github.com/Mellanox/bfscripts";
      license = licenses.bsd2;
      platforms = platforms.linux;
      maintainers = with maintainers; [ nikstur ];
    };
}
