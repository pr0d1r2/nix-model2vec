{
  description = "Nix package for model2vec — fast state-of-the-art static embeddings";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
    model2vec-src = {
      url = "github:MinishLab/model2vec/v0.8.1";
      flake = false;
    };
    nix-lefthook = {
      url = "github:pr0d1r2/nix-lefthook";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      model2vec-src,
      nix-lefthook,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = import ./model2vec.nix {
          inherit pkgs;
          src = model2vec-src;
        };
      });

      devShells = forAllSystems (pkgs: {
        ci = pkgs.mkShell {
          inputsFrom = [ nix-lefthook.devShells.${pkgs.stdenv.hostPlatform.system}.ci ];
          packages = [
            (import ./model2vec.nix {
              inherit pkgs;
              src = model2vec-src;
            })
          ];
        };

        default = pkgs.mkShell {
          inputsFrom = [ nix-lefthook.devShells.${pkgs.stdenv.hostPlatform.system}.ci ];
          packages = [
            (import ./model2vec.nix {
              inherit pkgs;
              src = model2vec-src;
            })
          ];
          shellHook = builtins.readFile ./dev.sh;
        };
      });
    };
}
