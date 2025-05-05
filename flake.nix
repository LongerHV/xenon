{
  description = "Xenon - Neovim configuration framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
      demoPackage = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configuration = import ./demo { inherit pkgs; };
        in
        pkgs.callPackage ./module/package.nix { inherit pkgs configuration; };
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

      nixosModules = import ./module/nixos.nix;
      homeManagerModules = import ./module/home-manager.nix;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
