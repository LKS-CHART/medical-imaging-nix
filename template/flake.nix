{
  description = "Code for the TBI neurosurgery prediction project";
  inputs.mi-flake.url = "github:LKS-CHART/medical-imaging-nix?ref=main";
  outputs = { self, mi-flake }:
   let
     version = builtins.substring 0 8 self.lastModifiedDate;
     supportedSystems = [ "x86_64-linux"  ];
     forAllSystems = mi-flake.inputs.nixpkgs.lib.genAttrs supportedSystems;
   in
     {devShell = forAllSystems (system: mi-flake.devShell.${system});
      packages = forAllSystems (system: { container = mi-flake.packages.${system}.container;
                                          contents = mi-flake.packages.${system}.contents; });
      defaultPackage = forAllSystems (system: self.packages.${system}.container);
     };
}
