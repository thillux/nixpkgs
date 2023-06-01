{ lib, stdenv, fetchpatch, fetchFromGitHub
, git, protobufc, pkgconfig, fuse3, meson, cmake, ninja
, libselinux, jitterentropy
, selinuxSupport ? false
, drng_chacha20 ? true
, ais2031Support ? true
, linux-devfiles ? true
, linux-getrandom ? true
, es_jitterRng ? true
, es_cpu ? true
, es_kernel ? true
, es_irq ? true
, es_sched ? true
, es_hwrand ? true
, hash_sha512 ? true
, hash_sha3_512 ? false
}:

stdenv.mkDerivation rec {
  pname = "esdm";
  version = "unstable-2023-04-05";

  src = fetchFromGitHub {
    owner = "smuellerDD";
    repo = "esdm";
    rev = "dc098ab1385cb272f583ee1b27232aedc3bb1a5e";
    sha256 = "sha256-CFlzfx+d4t9VTcFDjCbcdFP1WOQLLYcZ6qNJTtHwI5A=";
  };

  patches = [
  (fetchpatch {
    name = "esdm-fix-size.patch";
    url = "https://github.com/thillux/esdm/commit/668815d0eb30f0488e47a977f76db9095acff322.patch";
    hash = "sha256-1w5pPk27o+ZseJ10hkod86TRrnkt5hy75oG1VhgczqI=";
  })
  ];
  nativeBuildInputs = [ meson cmake pkgconfig ninja ];
  buildInputs = [ protobufc fuse3 jitterentropy libselinux ];

  mesonFlags = [
    "-Db_lto=false"
  ] ++ lib.lists.optional (!selinuxSupport) "-Dselinux=disabled"
   ++ lib.lists.optionals drng_chacha20 [
    "-Ddrng_hash_drbg=disabled"
    "-Ddrng_chacha20=enabled"
   ]
   ++ lib.lists.optional ais2031Support "-Dais2031=true"
   ++ lib.lists.optional (!linux-devfiles) "-Dlinux-devfiles=disabled"
   ++ lib.lists.optional (!linux-getrandom) "-Dlinux-getrandom=disabled"
   ++ lib.lists.optional (!es_jitterRng) "-Des_jent=disabled"
   ++ lib.lists.optional (!es_cpu) "-Des_cpu=disabled"
   ++ lib.lists.optional (!es_kernel) "-Des_kernel=disabled"
   ++ lib.lists.optional (!es_irq) "-Des_irq=disabled"
   ++ lib.lists.optional (!es_sched) "-Des_sched=disabled"
   ++ lib.lists.optional (!es_hwrand) "-Des_hwrand=disabled"
   ++ lib.lists.optional (!hash_sha512) "-Dhash_sha512=disabled"
   ++ lib.lists.optional (!hash_sha3_512) "-Dhash_sha3_512=disabled"
  ;

  meta = with lib; {
    homepage = "https://www.chronox.de/esdm.html";
    description = "Entropy Source and DRNG Manager in user space";
    license = [licenses.gpl2Only licenses.bsd3];
    platforms = platforms.all;
  };
}
