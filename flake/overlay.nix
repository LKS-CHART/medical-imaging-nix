{ orthanc_xnat_tools_src }: final: prev: {
  python311 = prev.python311.override { packageOverrides = pfinal: pprev: {
    # see https://github.com/NixOS/nixpkgs/issues/252616
    albumentations = pprev.albumentations.overridePythonAttrs (oa: {
      pythonImportsCheck = [ ];
    });
    qudida = pprev.qudida.overridePythonAttrs (oa: {
      pythonImportsCheck = [ ];
    });
    orthanc-xnat-tools = pfinal.buildPythonPackage rec {
      pname = "orthanc-xnat-tools";
      version = "1.2.0";

      src = orthanc_xnat_tools_src;
      propagatedBuildInputs = with pprev; [ numpy pandas pfinal.pydicom pyxnat tqdm ];

      #nativeCheckInputs = [ pprev.pytestCheckHook ];
      doCheck = false;
      pythonImportsCheck = [ "orthanc_xnat_tools" ];
    };

    pillow-jpls = pfinal.buildPythonPackage rec {
      pname = "pillow-jpls";
      version = "1.2.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/72/f3/725fd022d58e95374c0c6e8e3d183126938ffec580583fa2bf24a453191d/pillow_jpls-1.2.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-zpOAh+TPpO4YtleDfHXTtISpa3ibTbq9E7B4k2slhEA=";
      };

      propagatedBuildInputs = with pprev; [ pillow ];
    };

    highdicom = let
      test_data = prev.fetchFromGitHub {
        owner = "pydicom";
        repo = "pydicom-data";
        rev = "cbb9b2148bccf0f550e3758c07aca3d0e328e768";
        hash = "sha256-nF/j7pfcEpWHjjsqqTtIkW8hCEbuQ3J4IxpRk0qc1CQ=";
      }; in
    pfinal.buildPythonPackage rec {
      pname = "highdicom";
      version = "0.22.0";
      src = final.fetchFromGitHub {
        owner = "ImagingDataCommons";
        repo = "highdicom";
        rev = "refs/tags/v${version}";
        hash = "sha256-KHSJWEnm8u0xHkeeLF/U7MY4FfiWb6Q0GQQy2w1mnKw=";
      };

      preCheck = ''
        export HOME=$TMP/test-home
        mkdir -p $HOME/.pydicom/
        ln -s ${test_data}/data_store/data $HOME/.pydicom/data
      '';

      propagatedBuildInputs = with pfinal; [ numpy pillow pillow-jpls pydicom ];
      nativeCheckInputs = with pprev; [ pytestCheckHook ];
    };
    ipyevents = pfinal.buildPythonPackage rec {
      pname = "ipyevents";
      version = "2.0.1";
      src = pfinal.fetchPypi {
        inherit pname version;
        sha256 = "I+sq+rE9kFY5fxIKiAUd076wZ7aY0Iszrf/J4HfwGcs=";
      };
      propagatedBuildInputs = with pfinal; [ 
        ipywidgets jupyter-packaging
      ];
      pythonImportsCheck = "ipyevents";
      doCheck = false;
      postPatch = ''
              substituteInPlace setup.py --replace "ensure_python('>=3.6')" ""
              '';
    };
    ipyannotations = pfinal.buildPythonPackage rec {
      pname = "ipyannotations";
      version = "0.4.1";
      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/cb/8e/9f234cea70a44694ebba02622f976783510425ea43ebd4b9c57741ac708f/ipyannotations-0.4.1-py2.py3-none-any.whl";
        sha256 = "PFrmNOB78506ueYNFsFJFB2WyklM13bhPztuoVlIvP0=";
      };
      format = "wheel";
      propagatedBuildInputs = with pfinal; [ 
        ipywidgets ipycanvas palettable pillow ipyevents setupmeta numpy jupyter-packaging requests
      ];
    };
    itk-core = pfinal.buildPythonPackage rec {
      pname = "itk-core";
      version = "5.3.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/fe/00/22580238b122f4c0d38061764ce94e0f47c9b8c9fc24e4f6ade6a93f4563/itk_core-5.3.0-cp311-cp311-manylinux_2_28_x86_64.whl";
        hash = "sha256-fMJdCSPeuSGSmc2MWn5bwdjtZzFJegbPEhQJtxxyrlk=";
      };
      propagatedBuildInputs = with pfinal; [ numpy setuptools ];
    };
    itk-filtering = pfinal.buildPythonPackage rec {
      pname = "itk-filtering";
      version = "5.3.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/aa/57/34fb28f369f2cd2dc623b008b58ed05329cc60df3892ab0df8ff67faa24c/itk_filtering-5.3.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-lOzZLC1uzz7iSMV52CTo8Z1zZR7PeVtg9/4SpuhygQg=";
      };
      propagatedBuildInputs = with pfinal; [ numpy setuptools ];
    };
    itk-io = pfinal.buildPythonPackage rec {
      pname = "itk-io";
      version = "5.3.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/0d/87/55b0d962ceeb9991c6280bcb92a90078b7b2ed125abeb17d66143114596f/itk_io-5.3.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-ggORAuCKsKmoy4tpaBMLwvwm8QeF4fCJiA8Xaihfi0U=";
      };
      propagatedBuildInputs = with pfinal; [ numpy setuptools ];
    };
    itk-numerics = pfinal.buildPythonPackage rec {
      pname = "itk-numerics";
      version = "5.3.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/19/9f/83005ecdab1afecdf43e914df514abbdec494f8ca4373b0fae896e8b272c/itk_numerics-5.3.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-ctqJ8cLQ0HalrM0EwH2gpeRaEJG5DaGxeMRNzteiZhs";
      };
      propagatedBuildInputs = with pfinal; [ numpy setuptools ];
      pythonImportsCheck = [ ];
    };
    itk-registration = pfinal.buildPythonPackage rec {
      pname = "itk-registration";
      version = "5.3.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/d5/37/3c91bc2a6953047869dc8f4dfe3753ef235c3f8504505fd76f0a615295f3/itk_registration-5.3.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-v65fLo0pv3yideondgHnxH/NyXPV4crnuNpKsrcrHG4=";
      };
      propagatedBuildInputs = with pfinal; [ numpy setuptools ];
    };
    itk-segmentation = pfinal.buildPythonPackage rec {
      pname = "itk-segmentation";
      version = "5.3.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/34/4b/ef091e7e60e8476098729af850d21daefae666ff20148bc14cf7908d3017/itk_segmentation-5.3.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-uWTgxY2s/g1NGdkHQ8XDyLjed20mkThJZ8LATJdkh14=";
      };
      propagatedBuildInputs = with pfinal; [ numpy setuptools ];
    };
    itk = pfinal.buildPythonPackage rec {
      pname = "itk";
      version = "5.3.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/48/49/5c0275fac7513434b2ff85afb495e2c408f4fc216f616914c09f4cf2a94c/itk-5.3.0-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
        hash = "sha256-+xhql/6NgPQNAFj6Ywvoew6BtAPeo8+rqo6AmIL+KCI=";
      };
      propagatedBuildInputs = with pfinal; [
        itk-core
        itk-numerics
        itk-io
        itk-filtering
        itk-segmentation
        itk-registration
        numpy
      ];
      pythonImportsCheck = [ "itk" ];
    };
    simpleitk = pprev.simpleitk.overridePythonAttrs (oa: {
      propagatedBuildInputs = [ final.elastix final.itk final.simpleitk pfinal.numpy ];
    });
    superintendent = pfinal.buildPythonPackage rec {
      pname = "superintendent";
      version = "0.6.0";
      format = "pyproject";
      #format = "flit";
      postPatch = ''
        substituteInPlace pyproject.toml  \
          --replace "flit_core >=2,<3" "flit_core"  \
          --replace "psycopg2-binary" "psycopg2"
      '';
      src = pfinal.fetchPypi {
        inherit pname version;
        hash = "sha256-Qb/lwqmqJHDSiC12dcosuR41EQHT2ge7+8AGfvar2JM=";
      };
      nativeBuildInputs = with pfinal; [ flit-core ];
      propagatedBuildInputs = with pfinal; [
        ipywidgets
        numpy
        pandas
        scikit-learn
        scipy
        sqlalchemy
        pillow
        cachetools
        psycopg2
        ipyevents
        typing-extensions
      ];
    };
    antspyx = pfinal.buildPythonPackage rec {
      pname = "antspyx";
      version = "0.3.8";
      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/dd/2f/a81d5629ef8e545cffd86368756962682a7386a80601fe35387e4aaffa23/antspyx-0.3.8-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-q6xozoAph9JZ0naXX4vRbqsj6kldeH9WAe2R4CZDIS0=";
      };
      propagatedBuildInputs = with pfinal; [ matplotlib pyyaml scikitimage scikit-learn chart-studio nibabel statsmodels
                                             webcolors
                                           ];
      format = "wheel";
      pythonImportsCheck = [ "ants" ];
    };
    mdai = pfinal.buildPythonPackage rec {
      pname = "mdai";
      version = "0.12.2";
      src = pfinal.fetchPypi {
        inherit pname version;
        sha256 = "XC6n5fLMMQwkgSgxTyswUydGh+K6WqMzOJEkOZt0DPI=";
      };
      nativeBuildInputs = [ final.patchelf pprev.poetry-core ];
      propagatedBuildInputs = with pfinal; [ arrow matplotlib nibabel numpy opencv4 pandas pillow
	                                           pydicom requests retrying scikitimage tqdm dicom2nifti
                                             pyyaml
                                           ];
      format = "pyproject";
      pythonImportsCheck = [ "mdai" ];

      postPatch = ''
        substituteInPlace pyproject.toml --replace 'opencv-python ="*"' ""
      '';
    };
    logging_tree = pfinal.buildPythonPackage rec {
      pname = "logging_tree";
      version = "1.9";
      src = final.fetchFromGitHub {
        owner = "brandon-rhodes";
        repo = "logging_tree";
        rev = "b2d7cee13c0fe0a2601b5a2b705ff59375978a2f";
        sha256 = "wNAoiMXT9gO+eQc7RmtJ80YmwfEPf+JkmlGg3Ot2WFE=";
      };
      pythonImportsCheck = [ "logging_tree" ];
    };
    logx = pfinal.buildPythonPackage rec {
      pname = "logx";
      version = "0.1.1579232358";
      src = pfinal.fetchPypi {
        inherit pname version;
        sha256 = "1EYJAJesg3B9ebHfmP+Xf/cXJyGktjpdQH49CM8XHhU=";
      };
      pythonImportsCheck = [ "logx" ];
      nativeBuildInputs = [ pfinal.setuptools ];
      propagatedBuildInputs = with pfinal; [ 
        pyyaml logging_tree
      ];
      format = "pyproject";
    };
    pgnotify = pfinal.buildPythonPackage rec {
      pname = "pgnotify";
      version = "0.1.1561372201";
      src = pfinal.fetchPypi {
        inherit pname version;
        sha256 = "UJ3+Qv3ibG6rBmaYrcZ5zwJr9tGi/uoO1Y139sN2zpk=";
      };
      pythonImportsCheck = [ "pgnotify" ];
      propagatedBuildInputs = with pfinal; [ 
        logx psycopg2 six
      ];
      postPatch = ''
         substituteInPlace setup.py --replace "psycopg2-binary" "psycopg2"
      '';
    };
    charticles = with final; rPackages.buildRPackage {
      name = "charticles";
      src = fetchgit {
        url = "ssh://git@github.com/LKS-CHART/charticles";
        rev = "3bf371f";
        sha256 = "qYUpliKrEFM4PVOUrSfh/2Iffl898lL78zb9iVskc7c=";
      };
    };
  }; };
}
