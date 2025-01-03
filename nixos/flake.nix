{
  description = "A very basic flake to start. https://nixos.wiki/wiki/Flakes#Importing_packages_from_multiple_channels";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # Need to research this. 
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    ags.url = "github:Aylur/ags/v1"; # CHANGE THIS
    ags.inputs.nixpkgs.follows = "nixpkgs-unstable";

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, ... }@inputs:
    let 
      system = "x86_64-linux";
      overlay-unstable = final: prev: { 
        unstable = nixpkgs-unstable.legacyPackages.${prev.system}; 
      };
      overlay-stable = final: prev: { 
        stable = nixpkgs.legacyPackages.${prev.system}; 
      };
    in
      {
      nixosConfigurations."nixos-laptop" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ({config, pkgs, ...}: { nixpkgs.overlays = [ overlay-stable overlay-unstable ]; } )
          ./configuration.nix
          nixos-hardware.nixosModules.framework-13th-gen-intel
        ];
      };
    };
}
