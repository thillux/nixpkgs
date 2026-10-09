{
  stdenv,
  lib,
  src,
  version,
  gnat,
  gprbuild,
  fswatch,
  gnatcoll-core,
}:

stdenv.mkDerivation {
  pname = "ada-libfswatch";
  inherit src version;

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [
    fswatch
    gnatcoll-core
  ];

  env.LIBRARY_TYPE = "relocatable";

  # The Ada specification of the C API is generated from the headers, which
  # the Makefile expects in a writable libfswatch subdirectory. The installed
  # project refers to the shared libfswatch directly.
  postPatch = ''
    mkdir libfswatch
    cp -r ${fswatch}/include libfswatch/
    chmod -R u+w libfswatch
    substituteInPlace c_lib/c_libfswatch.gpr \
      --replace-fail '"../libfswatch"' '"${fswatch}"' \
      --replace-fail 'Library_Kind use "static"' 'Library_Kind use "relocatable"'
  '';

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  meta = {
    description = "Ada bindings to libfswatch";
    homepage = "https://github.com/AdaCore/ada_libfswatch";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
}
