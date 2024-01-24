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
  git gdown git-annex
  openssh
  less
  which
  curl wget
  zip unzip
  pigz  # for dcm2niix
  pandoc quarto
  dcm2niix dcmtk gdcm ants
  parallel
  ruff
  cudaPackages.cudatoolkit
  ] ++ glWrappers ++ [
  autoGlWrapper
  (emacsWithPackages (ps: with ps; [ magit ess poly-R elpy nix-mode ]))
  (with rPackages;
    # rWrapper bakes R_SITE_LIBS into the intepretter
    rWrapper.override {
      packages = [
        R
        #data_table
        #forecast
        #tidyverse
        #tidymodels
        #reticulate
        #keyring
        #dbplyr
        #pins
        #pROC
        #distr
        #lenses
        #openxlsx
        #wrapr
      ];
    })
    (python311.withPackages (ps: with ps; [
        accelerate
        addict
        albumentations
        batchgenerators
        cffi
        cloudpickle
        dask
        datasets
        dicom2nifti
        debugpy
        decorator
        defusedxml
        deid
        entrypoints
        evaluate
        einops
        grad-cam
        greenlet
        h5py
        highdicom
        httplib2
        hupper
        idna
        ignite
        imageio
        ipykernel
        ipython
        ipyniivue
        ipympl
        ipyannotations
        ipywidgets
        superintendent
        nibabel
        nipype
        antspyx
        iso8601
        jedi
        jinja2
        joblib
        json5
        jsonschema
        jupyter
        jupyter-client
        jupyter_console
        jupyterlab-pygments
        jupyterlab-widgets
        kaggle
        keyring
        keyrings-cryptfile
        kiwisolver
        #llvmlite
        markupsafe
        matplotlib
        mistune
        mlflow
        monai
        monai-deploy  # n.b.: breaks monai without highdicom
        msgpack
        munch
        mdai
        nbclient
        nbconvert
        nbdev
        nbformat
        nest-asyncio
        networkx
        notebook
        numpy
        oauthlib
        openpyxl
        #orthanc-rest-client
        orthanc-xnat-tools
        packaging
        pandas
        pandocfilters
        parso
        PasteDeploy
        peft
        pexpect
        pgnotify
        psycopg2
        pickleshare
        pillow
        pip
        prometheus-client
        protobuf
        pudb
        pycm
        pydicom
        pydicom-seg
        dicomweb-client
        pynetdicom
        pygments
        pynvml
        pyodbc
        pyorthanc
        pyparsing
        #pypx
        pyramid
        #pyramid_mailer
        pyrsistent
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
        pyxnat
        pyyaml
        pyzmq
        qtconsole
        requests
        rpy2
        safetensors
        scikitimage
        scikit-learn
        scipy
        sentencepiece
        sqlalchemy
        terminado
        terminaltables
        testpath
        text-unidecode
        polars
        pydantic
        pyradiomics
        torch
        pytorch-lightning
        rising
        simpleitk
        statsmodels
        tensorboard
        tensorboardx
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
        xnatpy
    ]))
]
