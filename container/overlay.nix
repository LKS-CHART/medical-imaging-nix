final: prev: {
        #singularity-tools = final.callPackage ./singularity-tools.nix {};
        cudatoolkit = prev.cudatoolkit_11_4;
        cudnn = prev.cudnn_8_3_cudatoolkit_11_4;
        python39 = prev.python39.override { packageOverrides = pfinal: pprev: {
          tensorflow = pprev.tensorflow-build.override ({
            cudaSupport = true;
            cudatoolkit = final.cudatoolkit;
            cudnn = final.cudnn;
          });
          ttach = pfinal.buildPythonPackage rec {
             pname = "ttach";
             version = "0.0.3";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "EgxN2IH+sOnI3WOxVPJlWJHD4gaJtoqU0WK/1VV7y0g=";
              };
             checkInputs = [ pfinal.pytest pfinal.pytorchWithCuda ];
          };
          torchvision = pprev.torchvision.override { pytorch = pfinal.pytorchWithCuda; };
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
             propagatedBuildInputs = with pfinal; [ numpy pytorchWithCuda pydeprecate ];
             checkInputs = with pfinal; [ pytest pytest-doctestplus pytestCheckHook ];
          };
          pytorch-lightning = (pprev.pytorch-lightning.override { pytorch = pfinal.pytorchWithCuda; }).overrideAttrs (oa: rec {
              propagatedBuildInputs = oa.propagatedBuildInputs ++ (with pfinal; [ pydeprecate torchmetrics fsspec ]);
              version = "1.6.3";
              src = final.fetchFromGitHub {
                owner = "PyTorchLightning";
                repo = oa.pname;
                rev = version;
                hash = "sha256-MEUFrj84y5lQfwbC9s9fJNOKo+Djeh+E/eDc8KeX7V4=";
              };
          });
          grad-cam = pfinal.buildPythonPackage rec {
             pname = "grad-cam";
             version = "1.3.7";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "y9LlgmgbP7X+Qdx+cs0Z4b1mXgPhgCX1IFCvLTI8ces=";
              };
             propagatedBuildInputs = with pfinal; [
               numpy pillow pytorchWithCuda torchvision ttach tqdm opencv3
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
          albumentations = pfinal.buildPythonPackage rec {
             pname = "albumentations";
             version = "1.1.0";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "YLBnswk5CLzFKtsqpdRPV+vbuKtXpHsLQvPcHTsc6CQ=";
              };
             propagatedBuildInputs = with pfinal; [
               numpy scipy scikitimage pyyaml qudida pytorchWithCuda torchvision imgaug
		     ];
		     checkInputs = [ pfinal.pytest ];
             postPatch = ''
               substituteInPlace setup.py --replace \
                 "install_requires=get_install_requirements(INSTALL_REQUIRES, CHOOSE_INSTALL_REQUIRES)" \
                 "install_requires=INSTALL_REQUIRES"
             '';
          };
          simpleitk = pfinal.buildPythonPackage rec {
            pname = "SimpleITK";
            version = "2.1.1";
            src = final.fetchurl {
              url = "https://files.pythonhosted.org/packages/1b/18/09df234e8af87affdaec05689f9e972a52b1c16956ec0b824cbb50d3ecab/SimpleITK-2.1.1-cp39-cp39-manylinux_2_12_x86_64.manylinux2010_x86_64.whl";
              sha256 = "/l4ZFPhfWCFe+GT0dLSkxkfJ5WkLj2kVioigWk5/qBo=";
            };
            nativeBuildInputs = [ final.patchelf ];
            format = "wheel";
            pythonImportsCheck = [ "SimpleITK" ];

            postFixup = let rpath = final.lib.makeLibraryPath [ final.stdenv.cc.cc.lib ];
                        in ''
                          lib=$out/${pfinal.python.sitePackages}/SimpleITK/_SimpleITK.cpython-39-x86_64-linux-gnu.so
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
               humanize scipy pytorchWithCuda tqdm
             ];
             checkInputs = with pfinal; [ pytest matplotlib ];
             pythonImportsCheck = [ "torchio" ];
          };
          fslpy = pfinal.buildPythonPackage rec {
             pname = "fslpy";
             version = "3.8.2";
             src = final.fetchgit {
                url = "https://git.fmrib.ox.ac.uk/fsl/fslpy";
                rev = "2089ed11";
                sha256 = "gRpIQTIRFYOvr5zlVfo0oN9NcdEdDahMbzGRmFzkex0=";
              };
             propagatedBuildInputs = with pfinal; [
               h5py nibabel numpy scipy 
             ];
             checkPhase = ''
               pytest tests/
             '';
             doCheck = false;
             checkInputs = with pfinal; [ pytest sphinx sphinx_rtd_theme coverage pytest-cov ];
             pythonImportsCheck = [ "fsl" ];
          };
           fsleyes-widgets =  pfinal.buildPythonPackage rec {
             pname = "fsleyes-widgets";
             version = "0.12.2";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "LpYHh4f48Al1GYip6d3qPIZYcAQCWEvMY9zMl0aY7pw=";
              };
             propagatedBuildInputs = with pfinal; [
               numpy matplotlib wxPython_4_0
             ];
             checkInputs = with pfinal; [ pytest sphinx sphinx_rtd_theme coverage pytest-cov ];
             pythonImportsCheck = [ "fsleyes_widgets" ];
             checkPhase = "pytest tests/";
             doCheck = false;
          }; 
           fsleyes-props = pfinal.buildPythonPackage rec {
             pname = "fsleyes-props";
             version = "1.7.3";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "1MNovmacyAt4bB4niK0e7HK5lwimLr8BrdSRTYBsBzg=";
              };
             propagatedBuildInputs = with pfinal; [
               numpy matplotlib wxPython_4_0 fsleyes-widgets fslpy
             ];
             checkInputs = with pfinal; [ pytest sphinx sphinx_rtd_theme coverage pytest-cov ];
             pythonImportsCheck = [ "fsleyes_props" ];
             doCheck = false;
          }; 
           fsleyes =  pfinal.buildPythonPackage rec {
             pname = "fsleyes";
             version = "1.3.3";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "zCbtJxwR30iXgTmkUc6FybrqqHZeDb4z0EB8sOW9XVE=";
              };
              nativeBuildInputs = [ final.wrapGAppsHook ];
              propagatedBuildInputs = with pfinal; [ jinja2 pillow pyopengl fsleyes-props fsleyes-widgets fslpy
                                                     matplotlib nibabel numpy pyparsing scipy setuptools wxPython_4_0 ];
              postPatch = ''
              substituteInPlace requirements.txt --replace "pyparsing==2.*" "pyparsing"
              '';
              doCheck = false;
          };
          pythreejs = pfinal.buildPythonPackage rec {
             pname = "pythreejs";
             version = "2.3.0";
             src = pfinal.fetchPypi {
                inherit pname version;
                sha256 = "Ixt/ztJIX6CUXgHk3RH7uS1K73Q3al6+bnxADcxOPCU=";
              };
              propagatedBuildInputs = with pfinal; [ ipywidgets ipydatawidgets ];
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
              propagatedBuildInputs = with pfinal; [ ipywidgets pythreejs ipywebrtc pillow ];
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
                ipywidgets ipycanvas palettable pillow ipyevents setupmeta numpy jupyter-packaging
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
          pybids = pfinal.buildPythonPackage rec {
            version = "0.14.0";
            pname = "pybids";

            src = pfinal.fetchPypi {
              inherit pname version;
              sha256 = "73c4d03aad333f2a7cb4405abe96f55a33cffa4b5a2d23fad6ac5767c45562ef";
            };

            propagatedBuildInputs = with pfinal; [
              click
              num2words
              numpy
              scipy
              pandas
              nibabel
              patsy
              bids-validator
              sqlalchemy
              formulaic
            ];

            checkInputs = with pfinal; [ pytestCheckHook ];
            pythonImportsCheck = [ "bids" ];
            postPatch = ''
              substituteInPlace setup.cfg --replace "formulaic ~=0.2.4" "formulaic"
              substituteInPlace setup.cfg --replace "sqlalchemy <1.4.0.dev0" "sqlalchemy"
              '';
            doCheck = false;
        };
        ipympl = pprev.ipympl.overrideAttrs (oa: {propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pfinal.pillow pfinal.matplotlib ];});
        antspyx = pfinal.buildPythonPackage rec {
            pname = "antspyx";
            version = "0.3.2";
            src = final.fetchurl {
              url = "https://files.pythonhosted.org/packages/8b/3f/7abecf79505f60c436320fcc0fc15cf83c224624928e8a41430cbf3b072c/antspyx-0.3.2-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
              sha256 = "/TzMU5UKt200Yel2PV99YJR5pPKgYdWj6gv0ph7UJNA=";
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
            version = "0.11.0";
            src = pfinal.fetchPypi {
              inherit pname version;
              sha256 = "87ZXPWe9H1fpWkeBIwZUCSVsWN+B+8KhNJX/Z8m+7Z8=";
            };
            nativeBuildInputs = [ final.patchelf pfinal.poetry ];
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
         optuna = with final; with pfinal; callPackage ./optuna.nix {};
	 ignite = with pfinal; pprev.ignite.override { pytorch = pytorchWithCuda; };
	 monai = with final; with pfinal; callPackage ./monai.nix {};
   einops = (pprev.einops.override { pytorch = pfinal.pytorchWithCuda;}).overridePythonAttrs (ps: { doCheck = false; });
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
