{
  description = "Xenon - Neovim configuration framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
      demoPackage = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configuration = import ./demo { inherit pkgs; };
        in
        pkgs.callPackage ./xenon/package.nix { inherit pkgs configuration; };
    in
    {
      apps = forAllSystems (system: {
        demo = {
          type = "app";
          program = "${demoPackage system}/bin/xenon";
        };
      });

      packages = forAllSystems (system: {
        demo = demoPackage system;
      });

      nixosModules = import ./xenon/nixos.nix;
      homeManagerModules = import ./xenon/home-manager.nix;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
