{ pkgs, lib, ... }:

{
  options.programs.xenon = with lib; {
    enable = mkEnableOption "xenon";
    package = mkPackageOption pkgs "neovim-unwrapped" { };
    finalPackage = mkOption {
      type = types.package;
      visible = false;
    };
    executable = mkOption {
      type = types.str;
      default = "xenon";
    };
    aliases = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    extraPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
    withPython3 = mkOption {
      type = types.bool;
      default = true;
    };
    withNodeJs = mkOption {
      type = types.bool;
      default = true;
    };
    initFile = mkOption {
      type = with types; nullOr path;
      default = null;
    };
    initFiles = mkOption {
      type = with types; listOf path;
      default = [ ];
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
    plugins = mkOption {
      type = types.listOf (types.submodule {
        options = {
          plugin = mkOption {
            type = types.package;
          };
          main = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          opts = mkOption {
            type = types.attrs;
            default = { };
          };
          configFile = mkOption {
            type = types.nullOr types.path;
            default = null;
          };
          preConfig = mkOption {
            type = types.lines;
            default = "";
          };
          postConfig = mkOption {
            type = types.lines;
            default = "";
          };
          dependencies = mkOption {
            type = types.listOf types.package;
            default = [ ];
          };
          extraPackages = mkOption {
            type = types.listOf types.package;
            default = [ ];
          };
        };
      });
      default = [ ];
    };
  };
}
