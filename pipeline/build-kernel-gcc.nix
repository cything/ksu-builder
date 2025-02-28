{
  pkgs,
  lib,
  stdenv,
  bc,
  bison,
  coreutils,
  cpio,
  elfutils,
  flex,
  gmp,
  kmod,
  libmpc,
  mpfr,
  nettools,
  openssl,
  pahole,
  perl,
  python3,
  rsync,
  ubootTools,
  which,
  zlib,
  zstd,
  # User args
  src,
  arch,
  defconfigs,
  kernelSU,
  susfs,
  makeFlags,
  additionalKernelConfig ? "",
  ...
}:
let
  finalMakeFlags = [
    "ARCH=${arch}"
    "O=$out"
  ] ++ makeFlags;

  defconfig = lib.last defconfigs;
  kernelConfigCmd = pkgs.callPackage ./kernel-config-cmd.nix {
    inherit
      arch
      defconfig
      defconfigs
      additionalKernelConfig
      kernelSU
      susfs
      finalMakeFlags
      ;
  };
in
stdenv.mkDerivation {
  name = "gcc-kernel";
  inherit src;

  nativeBuildInputs = [
    bc
    bison
    coreutils
    cpio
    elfutils
    flex
    gmp
    kmod
    libmpc
    mpfr
    nettools
    openssl
    pahole
    perl
    python3
    rsync
    ubootTools
    which
    zlib
    zstd
    pkgs.pkgsCross.aarch64-android.gcc
  ];

  buildPhase = ''
    runHook preBuild

    ${kernelConfigCmd}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make -j$(nproc) ${builtins.concatStringsSep " " finalMakeFlags}

    runHook postInstall
  '';

  dontFixup = true;
}
