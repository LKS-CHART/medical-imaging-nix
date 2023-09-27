{ pkgs, contents }:

with pkgs;
with pkgs.dockerTools;

buildImage {
  name = "test-docker";
  tag = "test";
  created = "now";
  copyToRoot = contents;
  diskSize = 1024*80;
  buildVMMemorySize = 1024*8;
}  
