{ pkgs }:

with pkgs;

let patched_rPackages =
   rPackages.override { overrides = {
     xml2 = rPackages.xml2.overrideDerivation (a: { installFlags = a.installFlags ++ ["--no-lock"]; })
   ;} ;};
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
  git gdown
  openssh
  less
  which
  curl wget
  zip unzip
  pandoc
  dcm2niix dcmtk gdcm simpleitk ants
  cudaPackages.cudatoolkit
  snakemake
  (nixgl.nvidiaPackages { version = "470.103.01"; sha256 = "19c7r3nrdi48vkzg6ykj7hfkgmvm49xhydj61hxlc4y2i6gk1hjn"; }).nixGLNvidia
  (emacsWithPackages (ps: with ps; [ magit ess poly-R elpy ]))
  (with patched_rPackages;
    # rWrapper bakes R_SITE_LIBS into the intepretter
    rWrapper.override {
      packages = [
        R
        batchtools
        tidyverse
        reticulate
	#charticles
        keyring
        dbplyr
        RMariaDB
        pROC
        distr
	lenses
	openxlsx
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
        catboost
        certifi
        cffi
        chardet
        cloudpickle
        cryptography
        cycler
        cython
        decorator
        defusedxml
        #efficientnet-pytorch
        entrypoints
        einops
        grad-cam
        greenlet
        h5py
        httplib2
        hupper
        idna
        imageio
        importlib-metadata
        ipykernel
        ipython
        ipython_genutils
        ipywidgets
        ipyvolume
        ipympl
        ipyannotations
        superintendent
        niwidgets
        #nipype
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
        jupyter_core
        jupyterlab-pygments
        jupyterlab-widgets
        kafka-python
        kaggle
	keras
        keyring
        keyrings-alt
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
        requests
        requests_oauthlib
        rpy2
        scikitimage
        scikit-learn
        scipy
        secretstorage
        send2trash
        six
        slicer
        sqlalchemy
        terminado
        terminaltables
        testpath
        text-unidecode
        pytorchWithCuda
        pytorch-lightning
        tensorflow
        torchvision
	torchmetrics
        simpleitk
        seaborn
        torchio
        tornado
        tqdm
        traitlets
        transaction
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
