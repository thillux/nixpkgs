{ stdenv
, lib
, fetchurl
, dpkg
}:

let
  binaries = [
    "mlx-mkbfb"
  ];
in
stdenv.mkDerivation rec {
  pname = "mlxbf-bootimages";

  mainVersion = "4.0.2";
  subVersion = "12679";

  version = "${mainVersion}-${subVersion}";

  src = fetchurl {
    url = "https://linux.mellanox.com/public/repo/bluefield/${mainVersion}/bootimages/prod/mlxbf-bootimages-signed_${version}_arm64.deb";
    sha256 = "sha256-N/0rEtGe1tmNgotRsEvEALY0X7HFBEACwpGn2kJfIxw=";
  };

  nativeBuildInputs = [
    dpkg
  ];

  unpackPhase = ''
    dpkg -x $src $out
    chmod -R 700 $out/
  '';

  meta = with lib;
    {
      description = "Collection of scripts used for BlueField SoC system management";
      homepage = "https://github.com/Mellanox/bootimages";
      # TODO fill out licenses (multiple)
      #license = licenses.bsd2;
      platforms = platforms.linux;
      maintainers = with maintainers; [ nikstur ];
    };
}
