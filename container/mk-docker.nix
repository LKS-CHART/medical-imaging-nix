{ pkgs, contents }:

with pkgs;
with pkgs.dockerTools;

buildImage {
  name = "test-docker";
  tag = "test";
  fromImage = pullImage {
      imageName = "ubuntu";
      imageDigest = "sha256:008c0f6712067722f42f9685476d37b0b7b689e31d66e5787d1920c7ac230849";
      sha256 = "04mwaqxpffh1jh703xfpd6n20dr836mlzrnhbpzawkppw5kyipfd";
      finalImageName = "ubuntu";
      finalImageTag = "23.04";
  };
  copyToRoot = contents;
  config = {
    Cmd = [ "bash" "-e" "echo hi" ];
    
  };
  diskSize = 1024*80;
  buildVMMemorySize = 1024*8;
}  
    
