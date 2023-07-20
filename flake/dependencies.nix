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
  gnutar
  gnused
  gawk
  watch
  openssl
  bashInteractive
  git gdown git-annex git-lfs datalad dvc
  openssh
  less
  which
  curl wget
  zip unzip
  pigz  # for dcm2niix
  pandoc quarto
  dcm2niix dcmtk gdcm ants
  parallel
  cudaPackages.cudatoolkit
  snakemake ] ++ glWrappers ++ [
  autoGlWrapper
  (emacsWithPackages (ps: with ps; [ magit ess poly-R elpy nix-mode ]))
  (with rPackages;
    # rWrapper bakes R_SITE_LIBS into the intepretter
    rWrapper.override {
      packages = [
        R
        batchtools
        data_table
        forecast
        tidyverse
        tidymodels
        reticulate
        #charticles
        keyring
        dbplyr
        RMariaDB
        pins
        pROC
        distr
        lenses
        openxlsx
        vetiver
        wrapr
      ];
    })
    (python310.withPackages (ps: with ps; [
        accelerate
        addict
        albumentations
        #apex
        #apiron
        argon2_cffi
        argon2-cffi-bindings
        #arviz
        asn1crypto
        async_generator
        attrs
        avro
        backcall
        batchgenerators
        bleach
        bitsandbytes
        bokeh
        catboost
        certifi
        cffi
        chardet
        cloudpickle
        cryptography
        cycler
        cython
        dask
        datasets
        dicom2nifti
        debugpy
        decorator
        defusedxml
        deid
        #efficientnet-pytorch
        entrypoints
        evaluate
        einops
        grad-cam
        #fastai
        fire  # for monai.bundle
        greenlet
        h5py
        heudiconv
        highdicom
        httplib2
        hupper
        idna
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
        nilearn
        nipype
        antspyx
        iso8601
        jax
        jaxlib
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
        kafka-python
        kaggle
        keyring
        keyrings-cryptfile
        kiwisolver
        lightgbm
        llvmlite
        markupsafe
        matplotlib
        mistune
        mlflow
        monai
        monai-deploy  # n.b.: breaks monai without highdicom
        msgpack
        munch
        mysql-connector
        mdai
        nbclient
        nbconvert
        nbdev
        nbformat
        nest-asyncio
        networkx
        notebook
        numba
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
        pbkdf2
        peft
        pexpect
        #pfmisc
        pgnotify
        psycopg2
        pickleshare
        pillow
        pip
        plaster
        plaster-pastedeploy
        #pretrainedmodels
        prometheus-client
        prompt-toolkit
        protobuf
        ptyprocess
        pudb
        pycm
        pycparser
        pycrypto
        pydicom
        pydicom-seg
        dicomweb-client
        pynetdicom
        pygments
        pynvml
        py-spy
        pyodbc
        pyorthanc
        pyparsing
        #pypx
        pyramid
        #pyramid_mailer
        pyrsistent
        pytest
        python-dateutil
        pytest-dotenv
        python-slugify
        python3-openid
        pytz
        pywavelets
        pyxdg
        pyxnat
        pyyaml
        pyzmq
        qtconsole
        qtpy
        qudida
        requests
        requests-cache
        requests_oauthlib
        rpy2
        safetensors
        scikitimage
        scikit-learn
        scipy
        secretstorage
        send2trash
        #slicer
        sqlalchemy
        tables
        terminado
        terminaltables
        testpath
        text-unidecode
        plotnine
        polars
        #pymc
        torch
        pytorch-lightning
        rising
        simpleitk
        seaborn
        sentencepiece
        #siuba
        #skorch
        statsmodels
        tensorboard
        tensorboardx
        torchvision
        torchmetrics
        timm
        torchio
        tornado
        tqdm
        traitlets
        transaction
        transformers
        translationstring
        ttach
        typing-extensions
        urllib3
        urwid
        venusian
        wcwidth
        webencodings
        widgetsnbextension
        wtforms
        xarray
        xgboost
        xnatpy
        zipp
    ]))
]
