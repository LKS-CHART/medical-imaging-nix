{ pkgs, contents, tag }:

pkgs.dockerTools.streamLayeredImage {
  name = "medical-imaging-nix";
  inherit tag;

  created = "now";

  inherit contents;
}
