{
  description = "NixOS configuration with CachyOS kernel and sowm";

  inputs = {
    # Use the NixOS 25.11 branch for stability with stateVersion 25.11
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # If you don't use stylix yet, you can remove the next two lines
    # stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, chaotic, ... }@inputs: {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        chaotic.nixosModules.default
        # stylix.nixosModules.stylix   # uncomment only if you add stylix config
      ];
    };
  };
}
