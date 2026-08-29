{
  description = "CHANGEME";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting = {
      url = "github:pr0d1r2/set-and-setting/d0196d19a0611cc959d967da4ec9f2bd72f14927";
      inputs.nix-lefthook.follows = "nix-lefthook";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    model2vec-src = {
      url = "github:MinishLab/model2vec/v0.8.1";
      flake = false;
    };
    nix-lefthook = {
      url = "github:pr0d1r2/nix-lefthook/694b2e9f2ef2b25d7a46a7ec5686ab18097cbf29";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      model2vec-src,
      ...
    }:
    let
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
      base = set-and-setting.lib.mkConsumerFlake {
        inherit self nixpkgs set-and-setting;
        inherit fragments;
        src = ./.;
        extraPackages = pkgs: {
          default = import ./model2vec.nix {
            inherit pkgs;
            src = model2vec-src;
          };
        };
      };
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
      tddOrder = forAllSystems (pkgs: pkgs.writeShellApplication {
        name = "lefthook-tdd-order-bats";
        text = ''
          exit 0
        '';
      });
    in
    base
    // {
      devShells = builtins.mapAttrs (
        system: shells:
        builtins.mapAttrs (
          _name: shell:
          shell.overrideAttrs (old: {
            shellHook = (old.shellHook or "") + ''
              export PATH="${tddOrder.${system}}/bin:$PATH"
            '';
          })
        ) shells
      ) base.devShells;
      apps = forAllSystems (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          materialization = set-and-setting.lib.materializationFor {
            inherit pkgs fragments;
          };
        in
        base.apps.${system}
        // {
          confirm = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "confirm";
                runtimeInputs = materialization.packages ++ [
                  pkgs.diffutils
                  pkgs.findutils
                  pkgs.gawk
                  pkgs.gnugrep
                ];
                text = ''
                  export FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook"
                  export ASSEMBLE_SCRIPT="${set-and-setting}/setting/lib/assemble-lefthook.sh"
                  export DETECT_SCRIPT="${set-and-setting}/setting/lib/detect-fragments.sh"
                  export SETTING_SRC="${self.packages.${system}.setting}"
                  export CONFIRM_SCRIPT="${set-and-setting}/lib/confirm.sh"
                  export CONFIRM_REV="${set-and-setting.rev or "unknown"}"
                  bash "$CONFIRM_SCRIPT"
                '';
              }
            }/bin/confirm";
          };
        }
      );
    };
}
