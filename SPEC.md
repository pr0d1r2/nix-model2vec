# SPEC — nix-model2vec

## §G GOAL

Standalone Nix package for [model2vec](https://github.com/MinishLab/model2vec) — fast state-of-the-art static embeddings. Pre-built via cachix (`pr0d1r2.cachix.org`). Consumed as flake input by downstream repos (nix-semble, etc.).

## §C CONSTRAINTS

- C1: Nix flake, nixpkgs follows `github:pr0d1r2/nixpkgs-lock` (fleet pin, currently `nixos-26.05`). Minimum nixpkgs: `nixos-26.05`. model2vec 0.10.0 needs `huggingface-hub>=1.0.0`, and `nixos-25.11` ships 0.35.3
- C2: 4 systems: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- C3: Source pinned as `flake = false` input
- C4: Python build via `buildPythonPackage` — setuptools backend
- C5: Core deps: huggingface-hub, jinja2, joblib, numpy, safetensors, tokenizers, tqdm
- C6: cachix binary cache in `nixConfig`
- C7: Tests disabled — require HuggingFace model downloads (⊥ nix sandbox)
- C8: 6 nix-lefthook inputs w/ follows deduplication
- C9: ⊥ embedded shell in nix — extract to fragments/

## §I INTERFACES

- I.pkg: `packages.<system>.default` — model2vec Python package
- I.dev: `devShells.<system>.default` — dev environment w/ model2vec + linters + lefthook
- I.flake-input: `inputs.nix-model2vec.url = "github:pr0d1r2/nix-model2vec"` w/ `nixpkgs.follows`; the followed nixpkgs must be `nixos-26.05` or newer (C1). Consumers on `nixos-25.11` stay on model2vec 0.8.1 or move to nixpkgs-lock

## §V VERSIONING

- model2vec version: pinned in model2vec.nix (currently 0.10.0)
- Bump: update `model2vec-src` input URL tag + version in model2vec.nix

## §T TESTING

- T1: `nix flake check` — evaluates package + devShell for all systems
- T2: `pythonImportsCheck` validates import
- T3: lefthook pre-commit quality gates

## §B BUILD

- B1: `nix build` — builds model2vec for current system
- B2: `nix develop` — enters dev shell
- B3: cachix push: `nix build && cachix push pr0d1r2 result`
