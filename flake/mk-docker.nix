{ pkgs, contents }:

pkgs.dockerTools.streamLayeredImage {
  name = "medical-imaging-nix";
  tag = "latest";

  created = "now";

  inherit contents;
}
