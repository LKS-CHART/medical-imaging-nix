{ pkgs, nvidiaDrivers }:

with pkgs;

let
  relevantDrivers =
    with builtins; filter (e: elem e.version nvidiaDrivers) nixgl.knownNvidiaDrivers;
  glWrappers =
    builtins.map (d:
      (nixgl.override {nvidiaVersion = d.version; nvidiaHash = d.sha256; }).nixGLNvidia)
      relevantDrivers;
  autoGlWrapper = import ./glWrapper.nix {inherit pkgs; };
in
[
  #coreutils
  #git
  #which
  #curl wget
  #zip unzip
  dockerTools.binSh
  pigz  # for dcm2niix
  dcm2niix
  ] ++ glWrappers ++ [
  autoGlWrapper
    (python310.withPackages (ps: with ps; [
        addict
        albumentations
        catboost
        lightgbm
        numpy
        pandas
        pretrainedmodels
        pydicom
        pynvml
        scikit-learn
        torch
        torchvision
        tqdm
        xgboost
    ]))
]
