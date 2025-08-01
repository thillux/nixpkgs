{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  testers,
  cmake,
  pkg-config,
  gtest,
  doxygen,
  graphviz,
  lomiri,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "properties-cpp";
  version = "0.0.3";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/lib-cpp/properties-cpp";
    rev = finalAttrs.version;
    hash = "sha256-C/BDEuKNMQHOjATO5aWBptjIlgfv6ykzjFAsHb6uP3Q=";
  };

  postPatch = ''
    # GTest needs C++17
    # Remove when https://gitlab.com/ubports/development/core/lib-cpp/properties-cpp/-/merge_requests/3 merged & in release
    substituteInPlace CMakeLists.txt \
      --replace-fail 'std=c++14' 'std=c++17'
  ''
  + lib.optionalString (!finalAttrs.finalPackage.doCheck) ''
    sed -i "/add_subdirectory(tests)/d" CMakeLists.txt
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    pkg-config
  ];

  buildInputs = [
    lomiri.cmake-extras
  ];

  checkInputs = [
    gtest
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { };
  };

  meta = with lib; {
    homepage = "https://gitlab.com/ubports/development/core/lib-cpp/properties-cpp";
    description = "Very simple convenience library for handling properties and signals in C++11";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ edwtjo ];
    platforms = platforms.linux;
    pkgConfigModules = [
      "properties-cpp"
    ];
  };
})
