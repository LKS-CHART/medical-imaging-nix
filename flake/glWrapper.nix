{ pkgs }:

pkgs.writeTextFile rec {
  name = "nixGL";
  text = ''#!${pkgs.runtimeShell}

  driver_file=/proc/driver/nvidia/version

  vers=$(${pkgs.gnugrep}/bin/grep "Module" "$driver_file"  |\
        ${pkgs.gnused}/bin/sed -E "s/.*Module  ([0-9.]+)  .*/\1/")
  if [ -z "$vers" ]; then
    echo "Failed to parse your driver version from $driver_file. Does $driver_file exist?"
    echo "Consider using nixGLNvidia-<version> directly instead."
    exit 1
  fi

  if ! command -v nixGLNvidia-"$vers" &> /dev/null; then
    echo -n "nixGLNvidia wrapper not found for $vers, it likely was not included "
    echo "in supportedNvidiaDrivers when this environment was built."
    exit 1
  fi

  exec nixGLNvidia-"$vers" "$@"  
  '';
  executable = true;
  destination = "/bin/${name}";
  checkPhase = ''
  ${pkgs.shellcheck}/bin/shellcheck "$out/bin/${name}"

  # Check that all the files listed in the output binary exists
  for i in $(${pkgs.pcre}/bin/pcregrep  -o0 '/nix/store/.*?/[^ ":]+' $out/bin/${name})
  do
    ls $i > /dev/null || (echo "File $i, referenced in $out/bin/${name} does not exists."; exit -1)
  done
  '';
}
