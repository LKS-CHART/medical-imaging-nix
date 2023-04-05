{ pkgs, nvidiaDrivers, defaultNvidiaDriver }:

with pkgs;

let patched_rPackages =
   rPackages.override { overrides = {
     xml2 = rPackages.xml2.overrideDerivation (a: { installFlags = a.installFlags ++ ["--no-lock"]; })
     ;} ;};
    relevant_drivers =
      with builtins; filter (e: elem e.version (nvidiaDrivers ++ [defaultNvidiaDriver])) nixgl.knownNvidiaDrivers;
    glWrappers =
      builtins.map (d:
        (nixgl.override {nvidiaVersion = d.version; nvidiaHash = d.sha256; }).nixGLNvidia)
        relevant_drivers;
    defaultDriver = with builtins; head (filter (e: e.version == defaultNvidiaDriver) relevant_drivers);
    defaultGlWrapper =
      (nixgl.override {nvidiaVersion = defaultDriver.version; nvidiaHash = defaultDriver.sha256; }).nixGLNvidia;
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
  git gdown git-annex git-lfs datalad
  openssh
  less
  which
  curl wget
  zip unzip
  pandoc quarto
  dcm2niix dcmtk gdcm simpleitk ants
  cudaPackages.cudatoolkit
  snakemake ] ++ glWrappers ++ [
  (nixgl.nixGLCommon defaultGlWrapper)
  (emacsWithPackages (ps: with ps; [ magit ess poly-R elpy nix-mode ]))
  (with patched_rPackages;
    # rWrapper bakes R_SITE_LIBS into the intepretter
    rWrapper.override {
      packages = [
        R
        batchtools
        data_table
        tidyverse
        tidymodels
        reticulate
        #charticles
        keyring
        dbplyr
        RMariaDB
        pROC
        distr
        lenses
        openxlsx
        wrapr
      ];
    })
    (python310.withPackages (ps: with ps; [
        addict
        #apex
        #apiron
        argon2_cffi
        argon2-cffi-bindings
        arviz
        asn1crypto
        async_generator
        attrs
        avro
        backcall
        bleach
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
        debugpy
        decorator
        defusedxml
        deid
        #efficientnet-pytorch
        entrypoints
        evaluate
        einops
        #grad-cam  # waiting for https://github.com/NixOS/nixpkgs/issues/220341
        fastai
        greenlet
        h5py
        httplib2
        hupper
        idna
        ignite
        imageio
        importlib-metadata
        ipykernel
        ipython
        ipywidgets
        ipympl
        ipyannotations
        superintendent
        #nipype
        antspyx
        iso8601
        jax
        jaxlibWithCuda
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
        keras
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
        packaging
        pandas
        pandocfilters
        parso
        PasteDeploy
        pbkdf2
        pexpect
        #pfmisc
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
        #pycm
        pycparser
        pycrypto
        pydicom
        pynetdicom
        pygments
        pyodbc
        pyorthanc
        pyparsing
        #pypx
        pyramid
        #pyramid_mailer
        pyrsistent
        python-dateutil
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
        scikitimage
        scikit-learn
        scipy
        secretstorage
        send2trash
        slicer
        sqlalchemy
        tables
        terminado
        terminaltables
        testpath
        text-unidecode
        plotnine
        polars
        pymc3
        pytorchWithCuda
        pytorch-lightning
        rising
        simpleitk
        seaborn
        sentencepiece
        siuba
        skorch
        statsmodels
        tensorflow
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
        zipp
    ]))
]
