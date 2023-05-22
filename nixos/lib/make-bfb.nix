{ stdenv 
, mlxbf-bootimages
, bfscripts
, kernel
, initrd
, init
, imgName ? "nixos.bfb"
}:

stdenv.mkDerivation {
  name = "nixos.bfb";

  nativeBuildInputs = [
    mlxbf-bootimages
    bfscripts
  ];

  buildCommand =
    ''
      mkdir -p $out

      boot_args=$(mktemp)
      boot_args2=$(mktemp)
      boot_path=$(mktemp)
      boot_desc=$(mktemp)

      printf "console=ttyAMA1 console=hvc0 console=ttyAMA0 earlycon=pl011,0x01000000 earlycon=pl011,0x01800000 initrd=initramfs ignore_loglevel init=${init}" > \
        "$boot_args"
      printf "console=ttyAMA1 console=hvc0 console=ttyAMA0 earlycon=pl011,0x13010000 initrd=initramfs ignore_loglevel init=${init}" > \
        "$boot_args2"

      printf "VenHw(F019E406-8C9C-11E5-8797-001ACA00BFC4)/Image" > "$boot_path"
      printf "NixOS bootstream" > "$boot_desc"

      ${bfscripts}/bin/mlx-mkbfb -v \
        --image "${kernel}" --initramfs "${initrd}" \
        --capsule "${mlxbf-bootimages}/lib/firmware/mellanox/boot/capsule/boot_update2.cap" \
        --boot-args-v0 "$boot_args" \
        --boot-args-v2 "$boot_args2" \
        --boot-path "$boot_path" \
        --boot-desc "$boot_desc" \
        "${mlxbf-bootimages}/lib/firmware/mellanox/boot/default.bfb" $out/${imgName}
    '';
}
