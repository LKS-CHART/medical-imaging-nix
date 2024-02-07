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
  ] ++ glWrappers ++ [
  autoGlWrapper
  (emacsWithPackages (ps: with ps; [ magit ess poly-R elpy nix-mode ]))
  (python311.withPackages (ps: with ps; [
        attrs
        avro
        backcall
        batchgenerators
        cffi
        decorator
        deid
        entrypoints
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
        mdai
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
        pgnotify
        psycopg
        (lib.lists.head psycopg.passthru.optional-dependencies.pool)
        pillow
        pip
        prometheus-client
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
        python-slugify
        pytz
        pyxdg
        pyxnat
        pyyaml
        requests
        safetensors
        scikitimage
        scikit-learn
        scipy
        secretstorage
        sqlalchemy
        polars
        pydantic
        torch
        pytorch-lightning
        simpleitk
        statsmodels
        tensorboard
        torchio
        torchvision
        torchmetrics
        tqdm
        traitlets
        transaction
        transformers
        ttach
        typing-extensions
        urllib3
        widgetsnbextension
        xnatpy
        zipp
    ]))
]
