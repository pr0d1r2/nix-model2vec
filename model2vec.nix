{ pkgs, src }:
pkgs.python313Packages.buildPythonPackage {
  pname = "model2vec";
  version = "0.10.0";
  pyproject = true;

  inherit src;

  env.SETUPTOOLS_SCM_PRETEND_VERSION = "0.10.0";

  build-system = with pkgs.python313Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pkgs.python313Packages; [
    huggingface-hub
    jinja2
    joblib
    numpy
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
