{
  description = "NixOS configuration with CachyOS kernel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, chaotic, stylix, ... }@inputs: {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        chaotic.nixosModules.default
        stylix.nixosModules.stylix
      ];
    };
  };
}
