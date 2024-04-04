{ pkgs, contents }:

with pkgs;
with pkgs.dockerTools;

buildLayeredImage {
  name = "test-docker";
  tag = "test";
  created = "now";
  contents = contents;
  #diskSize = 1024*80;
  #buildVMMemorySize = 1024*8;
}  
