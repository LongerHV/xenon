{
  xenon = { config, lib, pkgs, ... }:
    let
      cfg = config.programs.xenon;
    in
    {
      imports = [ ./module.nix ];
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ cfg.finalPackage ];
      };
    };
}
