{ pkgs, lib, config, ... }:

let
  doFile = file: "dofile(\"${file}\")";
  cfg = config.programs.xenon;
  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    inherit (cfg) withPython3 withNodeJs;
    plugins = (builtins.map (p: { inherit (p) plugin; }) cfg.plugins)
      ++ lib.concatMap (p: p.dependencies) cfg.plugins;
  };
  renderPluginConfig = p:
    let
      main = if p.main != null then p.main else p.plugin.pname;
      setupCommand = lib.optionalString (p.opts != { }) /* lua */ ''
        require("${main}").setup(vim.fn.json_decode([[${builtins.toJSON p.opts}]]))
      '';
      doConfigFileCommand = lib.optionalString (p.configFile != null) /* lua */ ''
        dofile("${p.configFile}")
      '';
      pluginConfig = lib.concatStrings (builtins.filter (s: s != "") [
        p.preConfig
        setupCommand
        doConfigFileCommand
        p.postConfig
      ]);
    in
    (lib.optionalString (pluginConfig != "") (lib.concatStrings [
      "-- Plugin ${p.plugin.pname}\n"
      pluginConfig
      "-- end\n"
    ]));
  wrapNeovim = pkgs.callPackage ./wrapper.nix { };
  wrappedPackage = wrapNeovim cfg.package (
    neovimConfig
    //
    {
      wrapperArgs = neovimConfig.wrapperArgs ++ (lib.optionalString (cfg.extraPackages != [ ]) [
        "--suffix"
        "PATH"
        ":"
        (lib.makeBinPath cfg.extraPackages)
      ]);
      luaRcContent = lib.concatStringsSep "\n" (lib.concatLists [
        (lib.optional (cfg.initFile != null) (doFile cfg.initFile))
        (builtins.map doFile cfg.initFiles)
        (lib.optional (cfg.extraConfig != null) cfg.extraConfig)
        (builtins.map renderPluginConfig cfg.plugins)
      ]);
    }
  );
  finalPackage = pkgs.runCommand "xenon" { } ''
    mkdir -p $out/bin
    ln -s ${wrappedPackage}/bin/nvim $out/bin/${cfg.executable}
  '';
in
{
  imports = [ ./options.nix ];
  config.programs.xenon = {
    inherit finalPackage;
    extraPackages = lib.concatMap (p: p.extraPackages) cfg.plugins;
  };
}
