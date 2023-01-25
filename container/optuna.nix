{ lib
, buildPythonPackage
, fetchFromGitHub
, pytest
, mock
, bokeh
, plotly
, chainer
, xgboost
, mpi4py
, lightgbm
, keras
, mxnet
, scikit-optimize
, tensorflow
, torch
, pytorch-lightning
, cma
, sqlalchemy
, fakeredis
, numpy
, scipy
, six
, cliff
, colorlog
, pandas
, alembic
, hypothesis
, cmaes
, tqdm
, typing
, pythonOlder
, isPy27
}:

buildPythonPackage rec {
  pname = "optuna";
  version = "3.0.5";
  disabled = isPy27;

  src = fetchFromGitHub {
    owner = "optuna";
    repo = pname;
    rev = "v${version}";
    sha256 = "TfAWL81a7GIePkPm+2uXinBP5jwnhWCZPp5GJjXOC6g=";
  };

  checkInputs = [
    pytest
    mock
    bokeh
    plotly
    chainer
    xgboost
    mpi4py
    lightgbm
    keras
    mxnet
    scikit-optimize
    tensorflow
    cma
    cmaes
    torch
    pytorch-lightning
    fakeredis
  ];

  propagatedBuildInputs = [
    sqlalchemy
    numpy
    scipy
    six
    cliff
    colorlog
    pandas
    alembic
    tqdm
  ] ++ lib.optionals (pythonOlder "3.5") [
    typing
  ];

  configurePhase = if !(pythonOlder "3.5") then ''
    substituteInPlace setup.py \
      --replace "'typing'," "" \
      --replace '"scipy>=1.7.0,<1.9.0"' '"scipy"'
  '' else ''
  '';

  checkPhase = ''
    pytest --ignore tests/test_cli.py \
           --ignore tests/test_dashboard.py \
           --ignore tests/integration_tests/test_chainermn.py \
           --ignore tests/integration_tests/test_pytorch_ignite.py \
           --ignore tests/integration_tests/test_botorch.py \
           --ignore tests/integration_tests/test_wandb.py \
           --ignore tests/integration_tests/test_fastai.py \
	   --ignore tests/integration_tests/test_fastaiv2.py \
	   --ignore tests/integration_tests/test_mlflow.py \
	   --ignore tests/integration_tests/test_skorch.py \
  	   --ignore tests/integration_tests/test_sklearn.py \
   	   --ignore tests/integration_tests/test_lightgbm.py \
	   --ignore tests/integration_tests/lightgbm_tuner_tests/test_optimize.py \
	   --ignore tests/integration_tests/allennlp_tests/test_allennlp.py \
	   --ignore tests/integration_tests/test_catalyst.py \
           --ignore tests/integration_tests/test_catboost.py
  '';
}
