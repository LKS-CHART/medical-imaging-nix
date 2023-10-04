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
  pandoc
  quarto
  postgresql
  dcm2niix
  ants
  parallel
  ruff
  #cudaPackages.cudatoolkit
  snakemake ] ++ glWrappers ++ [
  autoGlWrapper
  (emacsWithPackages (ps: with ps; [ magit ess poly-R elpy nix-mode ]))
  (python310.withPackages (ps: with ps; [
        attrs
        avro
        backcall
        batchgenerators
        cffi
        debugpy
        decorator
        defusedxml
        deid
        #efficientnet-pytorch
        entrypoints
        evaluate
        einops
        grad-cam
        ignite
        imageio
        importlib-metadata
        ipykernel
        ipython
        ipyniivue
        ipympl
        ipyannotations
        ipywidgets
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
        keyring
        keyrings-cryptfile
        matplotlib
        mistune
        monai
        mysql-connector
        mdai
        nbclient
        nbconvert
        nbdev
        nbformat
        networkx
        notebook
        numpy
        openpyxl
        #orthanc-rest-client
        orthanc-xnat-tools
        packaging
        pandas
        pandocfilters
        pgnotify
        psycopg
        pillow
        prometheus-client
        pycm
        pydicom
        pynetdicom
        pynvml
        py-spy
        pyodbc
        pyorthanc
        pyrsistent
        pytest
        pytest-dotenv
        pytest-postgresql
        python-dateutil
        python-dotenv
        python-hl7
        python-slugify
        pytz
        pyxnat
        pyyaml
        qtconsole
        requests
        safetensors
        scikitimage
        scikit-learn
        scipy
        secretstorage
        sqlalchemy
        polars
        pydantic
        pyradiomics
        torch
        pytorch-lightning
        simpleitk
        statsmodels
        tensorboard
        torchvision
        torchmetrics
        timm
        tqdm
        traitlets
        transaction
        transformers
        ttach
        typing-extensions
        urllib3
        widgetsnbextension
        wtforms
        xnatpy
        zipp
    ]))
]
