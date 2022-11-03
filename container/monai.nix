{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, ninja
, ignite
, numpy
, pybind11
, pytorchWithCuda
, which
}:

buildPythonPackage rec {
  pname = "monai";
  version = "1.0.1";
  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "Project-MONAI";
    repo = "MONAI";
    rev = version;
    sha256 = "sha256-92AkKB8XSl8tZYavVw/hRXkxfaBlpEDq0gdouMPmfUU=";
  };

  preBuild = ''
    export MAX_JOBS=$NIX_BUILD_CORES;
  '';

  nativeBuildInputs = [ ninja which ];
  buildInputs = [ pybind11 ];
  propagatedBuildInputs = [ numpy pytorchWithCuda ignite ];

  BUILD_MONAI = 1;

  doCheck = false;  # takes too long; numerous dependencies, some not in Nixpkgs

  pythonImportsCheck = [
    "monai"
    "monai.apps"
    "monai.data"
    "monai.engines"
    "monai.handlers"
    "monai.inferers"
    "monai.losses"
    "monai.metrics"
    "monai.optimizers"
    "monai.networks"
    "monai.transforms"
    "monai.utils"
    "monai.visualize"
  ];

  meta = with lib; {
    description = "Pytorch framework (based on Ignite) for deep learning in medical imaging";
    homepage = "https://github.com/Project-MONAI/MONAI";
    license = licenses.asl20;
    maintainers = [ maintainers.bcdarwin ];
  };
}
