{ pkgs, nvidiaDrivers }:

with pkgs;

let
  relevantDrivers =
    with builtins; filter (e: elem e.version nvidiaDrivers) nixgl.knownNvidiaDrivers;
  glWrappers =
    builtins.map (d:
      (nixgl.override {nvidiaVersion = d.version; nvidiaHash = d.sha256; }).nixGLNvidia)
      relevantDrivers;
  autoGlWrapper = import ./glWrapper.nix {inherit pkgs; };
in
[
  coreutils
  stdenv
  glibcLocales
  fontconfig
  gnugrep
  gnumake
  gnutar
  gnused
  gawk
  watch
  openssl
  bashInteractive
  git
  openssh
  less
  which
  curl wget
  zip unzip
  pandoc quarto
  parallel
  ruff
  cudaPackages.cudatoolkit
  ] ++ glWrappers ++ [
  autoGlWrapper
  (emacsWithPackages (ps: with ps; [ magit ess elpy nix-mode ]))
  (python311.withPackages (ps: with ps; [
    accelerate
    bitsandbytes
    dask
    datasets
    deid
    einops
    gensim
    grad-cam
    ipywidgets
    jinja2
    jupyter
    kaggle
    keyring
    keyrings-cryptfile
    langchain
    langchain-community
    llm
    matplotlib
    mlflow
    nbdev
    nbformat
    networkx
    nltk
    numpy
    openpyxl
    pandas
    peft
    pillow
    pip
    polars
    psycopg
    pydantic
    pynvml
    pyodbc
    pypdf
    pytest
    pytest-dotenv
    pytest-postgresql
    python-dateutil
    python-docx
    python-dotenv
    python-pptx
    python-slugify
    python3-openid
    pytorch-lightning
    pytz
    pywavelets
    pyxdg
    pyyaml
    requests
    safetensors
    scikit-learn
    scipy
    seaborn
    sentence-transformers
    sentencepiece
    spacy
    statsmodels
    tensorboard
    tensorboardx
    torch
    torchaudio
    torchmetrics
    torchvision
    tqdm
    transformers
    xformers
    xlrd
    ]))
]
