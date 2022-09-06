{ pkgs, contents }:

with pkgs;
with pkgs.singularity-tools;

buildImage {
  name = "test-container";
  runScript = "#!${stdenv.shell}\nexec /bin/sh $@";
  runAsRoot = ''
     #!${stdenv.shell}
     ${dockerTools.shadowSetup}
  '';

  inherit contents; 
  diskSize = 1024*80;
  memSize = 1024*8;
}
