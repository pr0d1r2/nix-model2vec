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
    set-and-setting.lib.mkConsumerFlake {
      inherit self nixpkgs set-and-setting;
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
      src = ./.;
      extraPackages = pkgs: {
        default = import ./model2vec.nix {
          inherit pkgs;
          src = model2vec-src;
        };
      };
    };
}
