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
  openjdk
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
    dash
    dash-bootstrap-components
    dash-core-components
    dash-html-components
    dask
    datasets
    deid
    einops
    evaluate
    flask
    faiss
    fastapi
    gensim
    grad-cam
    ipywidgets
    jaydebeapi
    jinja2
    jpype1
    jupyter
    kaggle
    keyring
    keyrings-cryptfile
    langchain
    langchain-community
    llm
    matplotlib
    mistralai
    mlflow
    nbdev
    nbformat
    networkx
    nltk
    numpy
    openpyxl
    ps.ollama
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
    rapidocr-onnxruntime
    requests
    safetensors
    scikit-learn
    scipy
    seaborn
    sentence-transformers
    sentencepiece
    spacy
    spacy-transformers
    statsmodels
    tensorboard
    tensorboardx
    torch
    torchaudio
    torchmetrics
    torchvision
    tqdm
    transformers
    vllm
    xformers
    xlrd
    ]))
]
