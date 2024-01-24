{
  description = "A container and dev environment for medical imaging data science";

  # Nixpkgs / NixOS version to use.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    #nixGL.url = "github:guibou/nixGL";
    nixGL.url = "github:cfhammill/nixGL";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR?rev=02f3cbbe58e290ef9759294c8d6a0ac5779a512a";

    orthanc_xnat_tools_src = {
      url = "git+ssh://git@172.27.10.122:12222/dsaa/orthanc-xnat-tools";
      flake = false;
    };
 
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixGL, nur, orthanc_xnat_tools_src, ... }:
    let

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Nvidia drivers to support
      supportedNvidiaDrivers = [
        "535.154.05"
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
            "8.0"
          ];
          overlays = [ nixGL.overlay nur.overlay pkgsOverlay.${system} ]; 
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
