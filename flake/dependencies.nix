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
  git-annex
  gdown
  openssh
  less
  which
  curl wget
  zip unzip
  pigz  # for dcm2niix
  dcm2niix
  parallel
  ruff
  sudo
  sops
  age
  ] ++ glWrappers ++ [
  autoGlWrapper
  (python311.withPackages (ps: with ps; [
        avro
        backcall
        batchgenerators
        cffi
        decorator
        deid
        entrypoints
        einops
        finetuning-scheduler
        fastapi
        grad-cam
        great-tables
        ibis-framework
        imageio
        importlib-metadata
        ipykernel
        ipython
        ipyniivue
        ipympl
        ipyannotations
        ipywidgets
        itk
        superintendent
        nibabel
        antspyx
        joblib
        jsonschema
        jupyter
        jupyter-client
        jupyter_console
        jupyterlab-pygments
        jupyterlab-widgets
        matplotlib
        mistune
        monai
        nbclient
        nbconvert
        nbformat
        networkx
        notebook
        numpy
        openpyxl
        #orthanc-rest-client
        orthanc-xnat-tools
        packaging
        pandas
        psycopg
        (lib.lists.head psycopg.passthru.optional-dependencies.pool)
        pillow
        pip
        polars
        prometheus-client
        pyarrow
        pycm
        pydicom
        pynetdicom
        pynvml
        pyodbc
        pyorthanc
        pyrsistent
        pytest
        pytest-dotenv
        pytest-mock
        pytest-postgresql
        python-dateutil
        python-dotenv
        python-hl7
        pytz
        pyxdg
        pyxnat
        pyyaml
        requests
        safetensors
        scikitimage
        scikit-learn
        scipy
        sentry-sdk
        skops
        sqlalchemy
        polars
        pydantic
        pydantic-settings
        torch
        pytorch-lightning
        simpleitk
        statsmodels
        summarytools
        tensorboard
        torchio
        torchvision
        torchmetrics
        tqdm
        traitlets
        transformers
        ttach
        urllib3
        uvicorn
        widgetsnbextension
        xnatpy
        xlrd
        ydata-profiling
        zipp
      ] ++ ibis-framework.optional-dependencies.postgres
        ++ ibis-framework.optional-dependencies.duckdb
        ++ ibis-framework.optional-dependencies.polars))
]
