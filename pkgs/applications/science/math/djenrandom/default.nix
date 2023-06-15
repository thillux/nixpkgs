{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "djenrandom";
  version = "unstable-2023-06-14";

  src = fetchFromGitHub {
    owner = "dj-on-github";
    repo = "djenrandom";
    rev = "2a18f8720d75e861c97daa60a43428ea6ebdbb49";
    sha256 = "sha256-8onopzzhEpzm9ciUaAi0KgBHlcGJSxLHLhNWIRuWUhs=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp djenrandom $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/dj-on-github/djenrandom";
    longDescription = ''
      A C program to generate random data using several random models,
      with parameterized non uniformities and flexible output formats. 
    '';
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ thillux ];
    platforms = platforms.unix;
  };
}
