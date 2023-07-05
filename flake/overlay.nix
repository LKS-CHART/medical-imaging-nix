{ orthanc_xnat_tools_src }: final: prev: {
  python310 = prev.python310.override { packageOverrides = pfinal: pprev: {
    pydicom-seg = pprev.pydicom-seg.overrideAttrs (oa: rec {
      version = "unstable-2023-05-16";
      src = final.fetchFromGitHub {
        owner = "razorx89";
        repo = oa.pname;
        rev = "1377e3e90ff34eb5087963e0b13e0ab15a3e4461";
        hash = "sha256-YW6vwOgDT3LkjIHlKLqlHerpQxcJ/tczQkztNhDM1Dk=";
        fetchSubmodules = true;
      };
      postPatch = oa.postPatch + ''
        substituteInPlace pyproject.toml --replace "^3.2.0" ">3.2.0"
      '';
    });
    bitsandbytes = pprev.bitsandbytes.overrideAttrs (oa: rec {
      version = "0.37.0";
      src = final.fetchFromGitHub {
        owner = "TimDettmers";
        repo = "bitsandbytes";
        rev = "refs/tags/${version}";
        hash = "sha256-f47oUHWxGxXXAwXUsPrnVKW5Vj/ncWnHWfEk1kQ1K+c=";
      };
    });
    orthanc-xnat-tools = pfinal.buildPythonPackage rec {
      pname = "orthanc-xnat-tools";
      version = "1.2.0";

      src = orthanc_xnat_tools_src;
      propagatedBuildInputs = with pprev; [ numpy pandas pydicom pyxnat tqdm ];

      #nativeCheckInputs = [ pprev.pytestCheckHook ];
      doCheck = false;
      pythonImportsCheck = [ "orthanc_xnat_tools" ];
    };

    pillow-jpls = pfinal.buildPythonPackage rec {
      pname = "pillow-jpls";
      version = "1.2.0";
      format = "wheel";

      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/c8/8f/e031b735a680f290aa00fec0720834f7b4de66ec339096be1913759b9b4a/pillow_jpls-1.2.0-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-0JeRmAGv6wojbyIDbLuuD99pj/l+k1BAhEEjp6P/Syk";
      };

      propagatedBuildInputs = with pprev; [ pillow ];
    };

    highdicom = let
      test_data = prev.fetchFromGitHub {
        owner = "pydicom";
        repo = "pydicom-data";
        rev = "bbb723879690bb77e077a6d57657930998e92bd5";
        hash = "sha256-dCI1temvpNWiWJYVfQZKy/YJ4ad5B0e9hEKHJnEeqzk=";
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

      preCheck = ''
        export HOME=$TMP/test-home
        mkdir -p $HOME/.pydicom/
        ln -s ${test_data}/data_store/data $HOME/.pydicom/data
      '';

      propagatedBuildInputs = with pfinal; [ numpy pillow pillow-jpls pydicom ];
      nativeCheckInputs = with pprev; [ pytestCheckHook ];
    };
    qudida = pfinal.buildPythonPackage rec {
      pname = "qudida";
      version = "0.0.4";
      src = pfinal.fetchPypi {
        inherit pname version;
        hash = "sha256-2xmOKIerDJqgAj5WWvv/Qd+3azYfhf1eE/eA11uhjMg=";
      };

      propagatedBuildInputs = with pfinal; [
        numpy scikit-learn typing-extensions opencv4
      ];
      nativeCheckInputs = [ pfinal.pytestCheckHook ];
      doCheck = false;  # no tests in PyPI dist

      postPatch = ''
        echo "numpy>=0.18.0" > requirements.txt
        echo "scikit-learn>=0.19.1" >> requirements.txt
        echo "typing-extensions" >> requirements.txt
        substituteInPlace setup.py --replace \
          "install_requires=get_install_requirements(INSTALL_REQUIRES, CHOOSE_INSTALL_REQUIRES)" \
          "install_requires=INSTALL_REQUIRES"
      '';
    };
    ipycanvas = pfinal.buildPythonPackage rec {
      pname = "ipycanvas";
      version = "0.11.0";
      src = pfinal.fetchPypi {
        inherit pname version;
        sha256 = "KXabR+J1utzjHe+3dIVF3S6nYKesunWJLgv6HFvFsXU=";
      };
      propagatedBuildInputs = with pfinal; [ 
        ipywidgets pillow numpy jupyter-packaging
      ];
      pythonImportsCheck = "ipycanvas";
      doCheck = false;
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
      version = "0.5.3";
      src = pfinal.fetchPypi {
        inherit pname version;
        sha256 = "kgWnXBgSOmwQmz7smiR0/Y1Aa9oZNa0fSiCm9Zu4OIw=";
      };
      format = "flit";
      propagatedBuildInputs = with pfinal; [ ipywidgets numpy pandas scikit-learn scipy schedule sqlalchemy pillow cachetools psycopg2 flask ipyevents typing-extensions ];
      postPatch = ''
              substituteInPlace pyproject.toml --replace "psycopg2-binary" "psycopg2"
              '';
    };
    antspyx = pfinal.buildPythonPackage rec {
      pname = "antspyx";
      version = "0.3.5";
      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/e8/1c/f324098ce15c330c1adff72b49220cb88815b208485bfb52795f2028100c/antspyx-0.3.5-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        sha256 = "y3LhIBPcQuEDr7GjgJIgSgMWIbX/2CW7ZQ1fwBYaF+k=";
      };
      # nativeBuildInputs = [ final.patchelf ];
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
