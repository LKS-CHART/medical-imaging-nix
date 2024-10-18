{ orthanc_xnat_tools_src }: final: prev: {
  python312 = prev.python312.override { packageOverrides = pfinal: pprev: {

    # see https://github.com/NixOS/nixpkgs/issues/252616
    albumentations = pprev.albumentations.overridePythonAttrs (oa: {
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
    codetiming = pfinal.buildPythonPackage rec {
      pname = "codetiming";
      version = "1.4.0";
      pyproject = true;

      src = final.fetchPypi {
        inherit pname version;
        hash = "sha256-STe/kTooFCWLh+qqQ9mhuyRxH/01V6mraTT6H+O6Dbw=";
      };

      nativeBuildInputs = [ pfinal.flit-core ];
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
        sqlmodel
        pillow
        cachetools
        codetiming
        psycopg2
        ipyevents
        typing-extensions
      ];

      pythonImportsCheck = [ "superintendent" ];
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
  }; };
}
