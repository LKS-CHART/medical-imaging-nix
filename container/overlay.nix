old-pkgs: final: prev: {
        dcmtk = old-pkgs.dcmtk;
        python310 = prev.python310.override { packageOverrides = pfinal: pprev: {
          opencv3 = pprev.opencv3.override { openblas = final.openblasCompat; };
          torch = pprev.torch.override { cudaSupport = true; };
          poetry = pprev.poetry.overrideAttr (af: ap: { postPatch = ''
            substituteInPlace pyproject.toml \
                  --replace 'crashtest = "^0.3.0"' 'crashtest = "*"' \
                  --replace 'xattr = { version = "^0.9.7"' 'xattr = { version = "^0.10.0"' \
                  --replace 'cleo = "^2.0.0"' ""
                                                                    ''; });
          tensorflow = pprev.tensorflow-build.override ({
            cudaSupport = true;
          });
          ttach = pfinal.buildPythonPackage rec {
             pname = "ttach";
             version = "0.0.3";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "EgxN2IH+sOnI3WOxVPJlWJHD4gaJtoqU0WK/1VV7y0g=";
              };
             checkInputs = [ pfinal.pytest pfinal.torch ];
          };
          #torchvision = pprev.torchvision.override { pytorch = pfinal.pytorchWithCuda; };
          pydeprecate = pfinal.buildPythonPackage rec {
             pname = "pyDeprecate";
             version = "0.3.1";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "+iaHCSTTR1Yhw0QEXCwBoWugNBE6kCYAx451s/rF9yw=";
              };
          };
          torchmetrics = pfinal.buildPythonPackage rec {
             pname = "torchmetrics";
             version = "0.7.3";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "h150Sm22PIh1cmDWPLgJGdA5hzSn9Fb46kGBuy25V9g=";
              };
             propagatedBuildInputs = with pfinal; [ numpy torch pydeprecate ];
             checkInputs = with pfinal; [ pytest pytest-doctestplus pytestCheckHook ];
          };
          lightning-utilities = pfinal.buildPythonPackage rec {
             pname = "lightning-utilities";
             version = "0.5.0";
             src = final.fetchFromGitHub {
                 owner = "Lightning-AI";
                 repo = "utilities";
                 rev = "v" + version;
                 hash = "sha256-J73sUmX1a7ww+rt1vwBt9P0Xbeoxag6jR0W63xEySCI=";
               };
             propagatedBuildInputs = with pfinal; [ fire typing-extensions packaging ];
             #checkInputs = with pfinal; [ pytestCheckHook ];
             doCheck = false;
          };
          pytorch-lightning = pprev.pytorch-lightning.overrideAttrs (oa: rec {
               propagatedBuildInputs = oa.propagatedBuildInputs ++
                 (with pfinal; [ pydeprecate torchmetrics fsspec croniter
                                 deepdiff arrow psutil beautifulsoup4 lightning-utilities
                                 inquirer tensorboardx
                                 ]);
               version = "1.8.6";
               src = final.fetchFromGitHub {
                 owner = "Lightning-AI";
                 repo = oa.pname;
                 rev = version;
                 hash = "sha256-5AyOCeRFiV7rdmoBPx03Xju6eTR/3jiE+HQBiEmdzmo=";
               };
               PACKAGE_NAME="pytorch";
               postPatch = ''
               substituteInPlace requirements/app/base.txt --replace "inquirer>=2.10.0" "inquirer"
               '';
          });
          grad-cam = pfinal.buildPythonPackage rec {
             pname = "grad-cam";
             version = "1.3.7";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "y9LlgmgbP7X+Qdx+cs0Z4b1mXgPhgCX1IFCvLTI8ces=";
              };
             propagatedBuildInputs = with pfinal; [
               numpy pillow torch torchvision ttach tqdm opencv3
             ];
             postPatch = ''
               substituteInPlace requirements.txt --replace "opencv-python" ""
             '';
          };
          qudida = pfinal.buildPythonPackage rec {
             pname = "qudida";
             version = "0.0.4";
             src = pfinal.fetchPypi {
                inherit pname version;
			sha256 = "2xmOKIerDJqgAj5WWvv/Qd+3azYfhf1eE/eA11uhjMg=";
		      };
             propagatedBuildInputs = with pfinal; [
               numpy scikit-learn typing-extensions opencv3
             ];
             postPatch = ''
               echo "numpy>=0.18.0" > requirements.txt
               echo "scikit-learn>=0.19.1" >> requirements.txt
               echo "typing-extensions" >> requirements.txt
               substituteInPlace setup.py --replace \
                 "install_requires=get_install_requirements(INSTALL_REQUIRES, CHOOSE_INSTALL_REQUIRES)" \
                 "install_requires=INSTALL_REQUIRES"
             '';
          };
          # albumentations = pfinal.buildPythonPackage rec {
          #    pname = "albumentations";
          #    version = "1.1.0";
          #    src = pfinal.fetchPypi {
          #       inherit pname version;
          #       sha256 = "YLBnswk5CLzFKtsqpdRPV+vbuKtXpHsLQvPcHTsc6CQ=";
          #     };
          #    propagatedBuildInputs = with pfinal; [
          #      numpy scipy scikitimage pyyaml qudida torch torchvision imgaug
	  #            ];
	  #            checkInputs = [ pfinal.pytest ];
          #    postPatch = ''
          #      substituteInPlace setup.py --replace \
          #        "install_requires=get_install_requirements(INSTALL_REQUIRES, CHOOSE_INSTALL_REQUIRES)" \
          #        "install_requires=INSTALL_REQUIRES"
          #    '';
          # };
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
             checkInputs = with pfinal; [ pytest matplotlib ];
             pythonImportsCheck = [ "torchio" ];
          };
          pythreejs = pfinal.buildPythonPackage rec {
             pname = "pythreejs";
             version = "2.4.1";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "C6UGOnYxLEX2XDds5F9a8zGZSEtM56WeeRrYxNdGqGc=";
              };
              propagatedBuildInputs = with pfinal; [ ipywidgets ipydatawidgets  ];
              doCheck = false;
          };
          ipywebrtc = pfinal.buildPythonPackage rec {
             pname = "ipywebrtc";
             version = "0.6.0";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "+Kw8wCs2M7WfOIrvZ5Yc/1f5ACj9MDuziGxjw9Yx2hM=";
              };
              propagatedBuildInputs = with pfinal; [ jupyter-packaging ];
              checkInputs = with pfinal; [ ipython ipywidgets ];
          };
          ipyvolume = pfinal.buildPythonPackage rec {
             pname = "ipyvolume";
             version = "0.5.2";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "Gcve6i2InNG7cPe4L4FIM60LPRFcgXHXt4YIUdj7vSY=";
              };
              propagatedBuildInputs = with pfinal; [ ipywidgets pythreejs ipywebrtc pillow requests ];
              checkInputs = with pfinal; [ pytest ];
              doCheck = false; # tries to do some headless browsing
          };
          niwidgets = pfinal.buildPythonPackage rec {
             pname = "niwidgets";
             version = "0.2.2";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "Qq98crGNaNl4NcjAW1uFf8CzQTzUJ/26kSWzRsLSc2o=";
              };
              propagatedBuildInputs = with pfinal; [ 
                nibabel nilearn ipywidgets ipyvolume matplotlib
                numpy scipy scikit-learn
              ];
              postPatch = ''
              substituteInPlace setup.py --replace "nilearn>=0.5.2,<0.6.0" "nilearn"
              substituteInPlace setup.py --replace "scikit-learn>=0.20.3,<0.21.0" "scikit-learn"
              substituteInPlace setup.py --replace "nibabel>=2.4,<3.0" "nibabel"
              substituteInPlace setup.py --replace "ipywidgets>=7.4,<8.0" "ipywidgets"
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
          interface_meta = pfinal.buildPythonPackage rec {
             pname = "interface_meta";
             version = "1.2.5";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "DIGRCsIAo0N5TbEwYndVkuTJbMnw1V6lOFzcOIlFsX0=";
              };
              propagatedBuildInputs = with pfinal; [ 
                setupmeta
              ];
          };
          formulaic = pfinal.buildPythonPackage rec {
             pname = "formulaic";
             version = "0.3.2";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "PhYmJWIUesve2hF413isGJqTvWPiNIJhvYtdMD8XP20=";
              };
              propagatedBuildInputs = with pfinal; [ 
                astor interface_meta numpy pandas scipy wrapt
              ];
              checkInputs = with pfinal; [ pytestCheckHook sympy ];
          };
          # pybids = pfinal.buildPythonPackage rec {
        #     version = "0.14.0";
        #     pname = "pybids";

        #     src = pfinal.fetchPypi {
        #       inherit pname version;
        #       sha256 = "73c4d03aad333f2a7cb4405abe96f55a33cffa4b5a2d23fad6ac5767c45562ef";
        #     };

        #     propagatedBuildInputs = with pfinal; [
        #       click
        #       num2words
        #       numpy
        #       scipy
        #       pandas
        #       nibabel
        #       patsy
        #       bids-validator
        #       sqlalchemy
        #       formulaic
        #     ];

        #     checkInputs = with pfinal; [ pytestCheckHook ];
        #     pythonImportsCheck = [ "bids" ];
        #     postPatch = ''
        #       substituteInPlace setup.cfg --replace "formulaic ~=0.2.4" "formulaic"
        #       substituteInPlace setup.cfg --replace "sqlalchemy <1.4.0.dev0" "sqlalchemy"
        #       '';
        #     doCheck = false;
        # };
        ipympl = pprev.ipympl.overrideAttrs (oa: {propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pfinal.pillow pfinal.matplotlib ];});
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
            nativeBuildInputs = [ final.patchelf final.poetry ];
            propagatedBuildInputs = with pfinal; [ arrow matplotlib nibabel numpy opencv3 pandas pillow
	                                           pydicom requests retrying scikitimage tqdm dicom2nifti
                                                   pyyaml
                                                 ];
            format = "pyproject";
            pythonImportsCheck = [ "mdai" ];

            postPatch = ''
	    substituteInPlace pyproject.toml --replace 'opencv-python ="*"' ""
	    '';
          };
          cmaes = pfinal.buildPythonPackage rec {
             pname = "cmaes";
             version = "0.8.2";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "HAS6I97ZJe8TuW9Cz71mepBepbgHVMdQ5kSLn82pal0=";
              };
             propagatedBuildInputs = with pfinal; [ numpy ];	     
          };
         pyorthanc = pfinal.buildPythonPackage rec {
            pname = "pyorthanc";
            version = "1.11.2";
            src = pfinal.fetchPypi {
               inherit pname version;
               sha256 = "mw92w4VO6HnjKy8Qof8Hidr5MpX6Dom5jxmA5flswNk=";
            };
            postPatch = ''
            substituteInPlace pyproject.toml --replace 'httpx = "^0.23.0"' ""
            substituteInPlace setup.py --replace "'httpx>=0.23.0,<0.24.0'" "'httpx'"
            substituteInPlace setup.py --replace "'pydicom>=2.3.0,<3.0.0'" "'pydicom'"
            '';
            propagatedBuildInputs = with pfinal; [ httpx pydicom requests ];
         };
         optuna = with final; with pfinal; callPackage ./optuna.nix {};
        };
        };
	charticles = with final; rPackages.buildRPackage {
		   name = "charticles";
		   src = fetchgit {
		     url = "ssh://git@github.com/LKS-CHART/charticles";
		     rev = "3bf371f";
		     sha256 = "qYUpliKrEFM4PVOUrSfh/2Iffl898lL78zb9iVskc7c=";
		   };
	};
      }
