{ lib, pkgs, configuration ? { }, ... }@specialArgs:

let
  modules = [
    (import ./module.nix)
    { programs.xenon = configuration; }
  ];
  result = lib.evalModules { inherit modules specialArgs; };
  cfg = result.config.programs.xenon;
in
cfg.finalPackage
