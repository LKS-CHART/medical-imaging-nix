{
  description = "A container and dev environment for medical imaging data science";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/4c3c80df545e";
  inputs.nixGL.url = "github:guibou/nixGL";
  inputs.nixGL.inputs.nixpkgs.follows = "nixpkgs";
 
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, nixGL, ... }:
    let

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux"  ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsOverlay = import ./container/overlay.nix;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (
        system: import nixpkgs { 
          inherit system; 
          config.allowUnfree = true; 
          overlays = [ pkgsOverlay nixGL.overlay ];  
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
