{
  lib,
  buildPythonPackage,

  fetchurl,

  # dependencies
  botan3,

  # build dependencies
  setuptools,
  setuptools-scm,
}:

let
  my-botan3 = botan3.overrideAttrs {
    src = fetchurl {
      url = "https://github.com/thillux/botan/archive/refs/heads/mtheil/python-definitions.tar.gz";
      hash = "sha256-+TzrU28fTi1/sKFTL42aJWkGRGtZtNiDdtcuQlTqrVY=";
    };
  };
in
buildPythonPackage rec {
  pname = "botan3";
  inherit (my-botan3) src version;
  format = "pyproject";

  propagatedBuildInputs = [ my-botan3 ];
  nativeBuildInputs = [ setuptools setuptools-scm ];

  postPatch = ''
    botanLibPath=$(find ${my-botan3.out}/lib -name 'libbotan-3.so' | head -n1)
    substituteInPlace botan3.py \
      --replace 'libbotan-3.so' "$botanLibPath"
  '';

  sourceRoot = "botan-mtheil-python-definitions/src/python";

  pythonImportsCheck = [ "botan3" ];

  meta = {
    description = "Python Bindings for botan3 cryptography library";
    homepage = "https://github.com/randombit/botan";
    changelog = "https://botan.randombit.net/news.html";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ thillux ];
  };
}
