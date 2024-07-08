{ orthanc_xnat_tools_src }: final: prev: {
  python311 = prev.python311.override { packageOverrides = pfinal: pprev: {
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
    # vllm = pprev.vllm.overrideAttrs {
    #   postPatch =
    #     ''
    #   substituteInPlace requirements.txt \
    #     --replace "xformers == 0.0.23.post1" "xformers == 0.0.24"
    #   substituteInPlace requirements.txt \
    #     --replace "cupy-cuda12x == 12.1.0" "cupy == 12.3.0"
    #   substituteInPlace requirements-build.txt \
    #     --replace "torch==2.1.2" "torch == 2.2.1"
    #   substituteInPlace pyproject.toml \
    #     --replace "torch == 2.1.2" "torch == 2.2.1"
    #   substituteInPlace requirements.txt \
    #     --replace "torch == 2.1.2" "torch == 2.2.1"
    # '';
    #};
    mistralai = pfinal.buildPythonPackage rec {
      pname = "mistralai";
      version = "0.4.1";
      pyproject = true;
      src = final.fetchFromGitHub {
        owner="mistralai";
        repo="client-python";
        rev="0.4.1";
        hash = "sha256-4FkQXqE/oJr3xNwp5qdX/aFHTpJCwMqzHREgbiO5VTA=";
      };
      nativeBuildInputs = [ pfinal.poetry-core ];
      propagatedBuildInputs = with pfinal; [ orjson pydantic httpx ];
      pythonImportCheckds = [ "mistralai" ];
    };
  }; };
}
