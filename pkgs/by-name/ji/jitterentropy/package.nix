{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "jitterentropy";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "thillux";
    repo = "jitterentropy-library";
    rev = "mtheil/ntg1-fixes";
    hash = "sha256-R+e7KZ53WfiXTI/m+OsLrbJIUohloxTs4OAdOk/vIHs=";
  };

  nativeBuildInputs = [ cmake ];

  outputs = [
    "out"
    "dev"
  ];

  postInstall = ''
    mkdir -p $out/tests
    find $NIX_BUILD_TOP/${src.name}/tests/raw-entropy/recording_userspace -name "*.sh" -exec cp {} $out/tests \;
    find $NIX_BUILD_TOP/${src.name}/tests/raw-entropy/validation-runtime -name "*.sh" -exec cp {} $out/tests \;
  '';

  hardeningDisable = [ "fortify" ]; # avoid warnings

  meta = {
    description = "Provides a noise source using the CPU execution timing jitter";
    homepage = "https://github.com/smuellerDD/jitterentropy-library";
    changelog = "https://github.com/smuellerDD/jitterentropy-library/raw/v${version}/CHANGES.md";
    license = with lib.licenses; [
      bsd3 # OR
      gpl2Only
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [
      johnazoidberg
      c0bw3b
    ];
  };
}
