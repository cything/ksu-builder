{
  lib,
  # Options
  arch,
  defconfig,
  defconfigs,
  additionalKernelConfig,
  kernelSU,
  susfs,
  finalMakeFlags,
}:
''
  export CFG_PATH=arch/${arch}/configs/${defconfig}
  cat >>$CFG_PATH <<EOF
  ${additionalKernelConfig}
  EOF
''
+ (lib.optionalString kernelSU.enable ''
  # Inject KernelSU options
  echo "CONFIG_MODULES=y" >> $CFG_PATH
  echo "CONFIG_KPROBES=y" >> $CFG_PATH
  echo "CONFIG_HAVE_KPROBES=y" >> $CFG_PATH
  echo "CONFIG_KPROBE_EVENTS=y" >> $CFG_PATH
  echo "CONFIG_OVERLAY_FS=y" >> $CFG_PATH
  echo "CONFIG_KSU=y" >> $CFG_PATH
'')
+ (lib.optionalString susfs.enable ''
  echo "CONFIG_KSU_SUSFS=y" >> $CFG_PATH
'')
+ ''
  mkdir -p $out
  make ${builtins.concatStringsSep " " (finalMakeFlags ++ defconfigs)}
''
