{ orthanc_xnat_tools_src }: final: prev: {
  python311 = prev.python311.override { packageOverrides = pfinal: pprev: {
    bitsandbytes = pprev.bitsandbytes.overrideAttrs (oa: rec {
      version = "0.37.0";
      src = final.fetchFromGitHub {
        owner = "TimDettmers";
        repo = "bitsandbytes";
        rev = "refs/tags/${version}";
        hash = "sha256-f47oUHWxGxXXAwXUsPrnVKW5Vj/ncWnHWfEk1kQ1K+c=";
      };
    });
    # highdicom tests don't pass with 2.4.x:
    pydicom = pprev.pydicom.overridePythonAttrs (oa: rec {
      version = "2.3.1";
      src = final.fetchFromGitHub {
        owner = "pydicom";
        repo = "pydicom";
        rev = "refs/tags/v2.3.1";
        hash = "sha256-xt0aK908lLgNlpcI86OSxy96Z/PZnQh7+GXzJ0VMQGA=";
      };
      disabledTests = pprev.pydicom.disabledTests ++ [
        "TestNumpy_NumpyHandler"
        "test_can_access_unsupported_dataset"
      ];
    });
    # see https://github.com/NixOS/nixpkgs/issues/252616
    albumentations = pprev.albumentations.overridePythonAttrs (oa: {
      pythonImportsCheck = [ ];
    });
    qudida = pprev.qudida.overridePythonAttrs (oa: {
      pythonImportsCheck = [ ];
    });
    # random failing diffusion test with downgraded pydicom; don't really care
    nibabel = pprev.nibabel.overridePythonAttrs (oa: {
      disabledTests = oa.disabledTests ++ [ "test_diffusion_parameters_strict_sort" ];
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
      version = "0.21.1";
      src = final.fetchFromGitHub {
        owner = "ImagingDataCommons";
        repo = "highdicom";
        rev = "refs/tags/v${version}";
        hash = "sha256-HAKlRt3kRM3OPpUwJ4jnZYUt3rtfjjdgsE/tQCHt1WI";
      };

      patches = [
        (final.fetchpatch {
          name = "pillow-10-api-updates";
          url = "https://github.com/ImagingDataCommons/highdicom/commit/f453e7831e243e1f4d8493bfa79238a264c6e6b1.patch";
          hash = "sha256-JUJv8oKpUWjHH15i6lpwYZj3giQzoT2Dq3XdHwbJ0Kc=";
        })
      ];

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
    python-hl7 = pfinal.buildPythonPackage rec {
      pname = "python-hl7";
      version = "0.4.5";
      format = "pyproject";
      src = final.fetchFromGitHub {
        owner = "johnpaulett";
        repo = "python-hl7";
        rev = "refs/tags/${version}";
        hash = "sha256-9uFdyL4+9KSWXflyOMOeUudZTv4NwYPa0ADNTmuVbqo=";
      };
      nativeBuildInputs = with pfinal; [ setuptools wheel ];
      nativeCheckInputs = with pfinal; [ pytestCheckHook ];
      pythonImportsCheck = [ "hl7" ];
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
