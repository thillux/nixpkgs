{ lib
, stdenv
, fetchFromGitHub
, mpfr
, gmp
}:

stdenv.mkDerivation rec {
  pname = "djent";
  version = "unstable-2022-10-13";

  src = fetchFromGitHub {
    owner = "dj-on-github";
    repo = "djent";
    rev = "5d62e79bdb7857710d3582daf06f5e394bf56fc6";
    sha256 = "sha256-inMh7l/6LlrVnIin+L+fj+4Lchk0Xvt09ngVrCuvphE=";
  };

  buildInputs = [ mpfr gmp ];

  installPhase = ''
    mkdir -p $out/bin
    cp djent $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/dj-on-github/djent";
    longDescription = ''
      A reimplementation of the Fourmilab/John Walker
      random number test program ent with several improvements.
    '';
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ thillux ];
    platforms = platforms.unix;
  };
}
