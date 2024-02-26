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
        bitsandbytes
        dask
        datasets
        deid
        grad-cam
        jinja2
        jupyter
        kaggle
        keyring
        keyrings-cryptfile
        matplotlib
        mlflow
        nbdev
        nbformat
        networkx
        numpy
        openpyxl
        pandas
        peft
        psycopg
        pillow
        pip
        pynvml
        pyodbc
        pytest
        pytest-dotenv
        pytest-postgresql
        python-dateutil
        python-dotenv
        python-slugify
        python3-openid
        pytz
        pywavelets
        pyxdg
        pyyaml
        requests
        safetensors
        scikit-learn
        scipy
        polars
        pydantic
        torch
        pytorch-lightning
        seaborn
        tensorboard
        tensorboardx
        torchmetrics
        tqdm
        transformers
    ]))
]
