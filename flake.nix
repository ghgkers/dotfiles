{
  description = "Ultimate NixOS Gaming + sowm (CachyOS kernel)";

  inputs = {
    # Stable base, but we'll overlay CachyOS kernel for speed
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Chaotic Nyx – provides CachyOS kernel & extra gaming packages
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, chaotic, ... }@inputs: {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        chaotic.nixosModules.default
        # Enable the chaotic overlay (so we can use linuxPackages_cachyos-lto)
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ chaotic.overlays.default ];
        })
      ];
    };
  };
}
