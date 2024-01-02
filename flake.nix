{
  description = "A container and dev environment for medical imaging data science";

  # Nixpkgs / NixOS version to use.
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    #nixGL.url = "github:guibou/nixGL";
    nixGL.url = "github:cfhammill/nixGL";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";

    orthanc_xnat_tools_src = {
      url = "git+ssh://git@curtcsrv.unity.local:12222/dsaa/orthanc-xnat-tools";
      flake = false;
    };
 
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixGL, orthanc_xnat_tools_src, ... }:
    let

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Nvidia drivers to support
      supportedNvidiaDrivers = [
        "535.129.03"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsOverlay = forAllSystems (system: import ./flake/overlay.nix { inherit orthanc_xnat_tools_src; });

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (
        system: import nixpkgs { 
          inherit system; 
          config.allowUnfree = true;
          config.cudaSupport = true;
          config.cudaCapabilities = [
            "7.5"
            "8.0"
          ];
          overlays = [ pkgsOverlay.${system} nixGL.overlay ]; 
        });

      # Import the relevant dependencies
      contentsFor = forAllSystems
        (system: import ./flake/dependencies.nix {
          pkgs = nixpkgsFor.${system};
          nvidiaDrivers = supportedNvidiaDrivers;
        });

    in

    {
      devShell = forAllSystems (
        system: import ./flake/devenv.nix { 
          pkgs = nixpkgsFor.${system}; contents = contentsFor.${system}; 
        });
      packages = forAllSystems (
        system: { 
          singularity = import ./flake/mk-singularity.nix {pkgs = nixpkgsFor.${system}; 
                                                               contents = contentsFor.${system}; 
                                                              };
          docker = import ./flake/mk-docker.nix {pkgs = nixpkgsFor.${system};
                                                     contents = contentsFor.${system};
                                                    };
        });
      templates = {
        mi-flake = {
          path = ./template;
          description = "A flake for medical imaging AI";
        };};
      defaultPackage = forAllSystems (system: self.devShell.${system});
      defaultTemplate = self.templates.mi-flake;
    };
}
