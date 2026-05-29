{ pkgs, src }:
pkgs.python313Packages.buildPythonPackage {
  pname = "model2vec";
  version = "0.8.1";
  pyproject = true;

  inherit src;

  build-system = with pkgs.python313Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pkgs.python313Packages; [
    jinja2
    joblib
    numpy
    rich
    safetensors
    tokenizers
    tqdm
  ];

  pythonImportsCheck = [ "model2vec" ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Fast state-of-the-art static embeddings";
    homepage = "https://github.com/MinishLab/model2vec";
    license = licenses.mit;
  };
}
