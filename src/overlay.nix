old-pkgs: final: prev: {
  python310 = prev.python310.override { packageOverrides = pfinal: pprev: {
    # remove `torch` and `tensorflow` overrides when config.enableCuda is set
    # after https://github.com/NixOS/nixpkgs/issues/220341 is resolved
    torch = pprev.torch.override {
      cudaSupport = true;
    };
    tensorflow = pprev.tensorflow-build.override ({
      cudaSupport = true;
    });
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
    simpleitk = pfinal.buildPythonPackage rec {
      pname = "SimpleITK";
      version = "2.2.1";
      src = final.fetchurl {
        url = "https://files.pythonhosted.org/packages/ff/0b/2e078bb5fe33f7fef38bdeb882c23bc73782aecc66bb08047834c5c4a99c/SimpleITK-2.2.1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        sha256 = "f5Y6cV7uKu2VzJoLcGYjGwlE+F6Z9lzA4hahWikcQyA=";
      };
      nativeBuildInputs = [ final.patchelf ];
      format = "wheel";
      pythonImportsCheck = [ "SimpleITK" ];

      postFixup = let rpath = final.lib.makeLibraryPath [ final.stdenv.cc.cc.lib ];
                  in ''
                          lib=$out/${pfinal.python.sitePackages}/SimpleITK/_SimpleITK.cpython-310-x86_64-linux-gnu.so
                          patchelf --set-rpath "${rpath}" "$lib"
                           '';          
    };
    torchio = pfinal.buildPythonPackage rec {
      pname = "torchio";
      version = "0.18.75";
      src = pfinal.fetchPypi {
        inherit pname version;
        sha256 = "OjrVQTMcgW+sBwL9IqeLtqtv+CQsP+lu5t5fyGti0EU=";
      };
      propagatedBuildInputs = with pfinal; [
        simpleitk deprecated nibabel click
        humanize scipy torch tqdm
      ];
      preCheck = ''export HOME=$(mktemp -d)'';
      nativeCheckInputs = with pfinal; [ pytest matplotlib ];
      pythonImportsCheck = [ "torchio" ];
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

      /*postFixup = let rpath = final.lib.makeLibraryPath [ final.stdenv.cc.cc.lib ];
                        in ''
                          lib=$out/${pfinal.python.sitePackages}/SimpleITK/_SimpleITK.cpython-39-x86_64-linux-gnu.so
                          patchelf --set-rpath "${rpath}" "$lib"
                           '';       */   
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
    optuna = with final; with pfinal; callPackage ./overlays/optuna/optuna.nix {};
    #widgetsnbextension = with final; with pfinal;
    #  callPackage ./overlays/widgetsnbextension/widgetsnbextension.nix {};
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
