{
  description = "A container and dev environment for medical imaging data science";

  # Nixpkgs / NixOS version to use.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixGL.url = "github:guibou/nixGL";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";
 
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixGL, ... }:
    let

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsOverlay = forAllSystems (system: import ./container/overlay.nix { }); #(import nixpkgs-old {inherit system;}));

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (
        system: import nixpkgs { 
          inherit system; 
          config.allowUnfree = true;
          #config.cudaSupport = true;  # waiting on https://github.com/NixOS/nixpkgs/issues/220341
          config.cudaCapabilities = [ "7.5" ];
          overlays = [ pkgsOverlay.${system} nixGL.overlay ]; 
        });

      # Import the relevant dependencies
      contentsFor = forAllSystems (system: import ./container/dependencies.nix { pkgs = nixpkgsFor.${system}; });

    in

    {
      devShell = forAllSystems (
        system: import ./container/devenv.nix { 
          pkgs = nixpkgsFor.${system}; contents = contentsFor.${system}; 
        });
      packages = forAllSystems (
        system: { 
          container = import ./container/mk-container.nix {pkgs = nixpkgsFor.${system}; 
          contents = contentsFor.${system}; 
        };});
      templates = {
        mi-flake = {
          path = ./template;
          description = "A flake for medical imaging AI";
        };};
      defaultPackage = forAllSystems (system: self.packages.${system}.container);
      defaultTemplate = self.templates.mi-flake;
    };
}
