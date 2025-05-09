{
  stdenv,
  lib,
  replaceVarsWith,
  coreutils,
  getopt,
  runtimeShell,
  modDirVersion ? "",
  forPlatform ? stdenv.buildPlatform,
}:

replaceVarsWith {
  name = "uname";

  src = ./deterministic-uname.sh;

  dir = "bin";
  isExecutable = true;

  replacements = {
    inherit coreutils getopt runtimeShell;

    uSystem = if forPlatform.uname.system != null then forPlatform.uname.system else "unknown";
    inherit (forPlatform.uname) processor;

    # uname -o
    # maybe add to lib/systems/default.nix uname attrset
    # https://github.com/coreutils/coreutils/blob/7fc84d1c0f6b35231b0b4577b70aaa26bf548a7c/src/uname.c#L373-L374
    # https://stackoverflow.com/questions/61711186/where-does-host-operating-system-in-uname-c-comes-from
    # https://github.com/coreutils/gnulib/blob/master/m4/host-os.m4
    operatingSystem =
      if forPlatform.isLinux then
        "GNU/Linux"
      else if forPlatform.isDarwin then
        "Darwin" # darwin isn't in host-os.m4 so where does this come from?
      else if forPlatform.isFreeBSD then
        "FreeBSD"
      else
        "unknown";

    # in os-specific/linux module packages
    # --replace '$(shell uname -r)' "${kernel.modDirVersion}" \
    # is a common thing to do.
    modDirVersion = if modDirVersion != "" then modDirVersion else "unknown";
  };

  meta = with lib; {
    description = "Print certain system information (hardcoded with lib/system values)";
    mainProgram = "uname";
    longDescription = ''
      This package provides a replacement for `uname` whose output depends only
      on `stdenv.buildPlatform`, or a configurable `forPlatform`.  It is meant
      to be used from within derivations. Many packages' build processes run
      `uname` at compile time and embed its output into the result of the build.
      Since `uname` calls into the kernel, and the Nix sandbox currently does
      not intercept these calls, builds made on different kernels will produce
      different results.
    '';
    license = [ licenses.mit ];
    maintainers = with maintainers; [ artturin ];
    platforms = platforms.all;
  };
}
