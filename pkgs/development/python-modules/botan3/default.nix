{
  lib,
  buildPythonPackage,

  # dependencies
  botan3,

  # build dependencies
  setuptools,
}:

buildPythonPackage rec {
  pname = "botan3";
  inherit (botan3) src version;
  format = "pyproject";

  propagatedBuildInputs = [ botan3 ];
  nativeBuildInputs = [ setuptools ];

  postPatch = ''
    botanLibPath=$(find ${botan3.out}/lib -name 'libbotan-3.so' | head -n1)
    substituteInPlace src/python/botan3.py \
      --replace 'libbotan-3.so' "$botanLibPath"

    cp ${./pyproject.toml} pyproject.toml
  '';

  pythonImportsCheck = [ "botan3" ];

  meta = {
    description = "Python Bindings for botan3 cryptography library";
    homepage = "https://github.com/randombit/botan";
    changelog = "https://botan.randombit.net/news.html";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ thillux ];
  };
}
