{ pkgs }:

pkgs.writeTextFile rec {
  name = "nixGL";
  text = ''#!${pkgs.runtimeShell}

  vers=$(${pkgs.gnugrep}/bin/grep "Module" /proc/driver/nvidia/version |\
        ${pkgs.gnused}/bin/sed -E "s/.*Module  ([0-9.]+)  .*/\1/")
  if [ -z "$vers" ]; then
    echo "Failed to find your driver version"
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
