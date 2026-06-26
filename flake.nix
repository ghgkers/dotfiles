{
  description = "Ultimate Portable NixOS Gaming Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";[cite: 2]
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";[cite: 2]
  };

  outputs = { self, nixpkgs, chaotic, ... }@inputs: {
    nixosConfigurations = {
      nix-gaming = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };[cite: 2]
        modules = [
          ./hosts/rog-strix/hardware-configuration.nix
          ./hosts/rog-strix/hardware-spec.nix
          ./configuration.nix
          chaotic.nixosModules.default[cite: 2]
        ];
      };
    };
  };
}
