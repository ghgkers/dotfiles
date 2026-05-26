{
  description = "Ultimate NixOS Gaming + sowm (CachyOS kernel)";

  inputs = {
    # 25.11 — отличный выбор для стабильности
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Chaotic Nyx для ядра CachyOS
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, chaotic, ... }@inputs: {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        chaotic.nixosModules.default # Этого достаточно, оверлей подключится сам
      ];
    };
  };
}
