# Copyright (c) 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{ beautifulsoup4
, bleach
, buildPythonPackage
, defusedxml
, fetchPypi
, fetchpatch
, ipywidgets
, jinja2
, jupyterlab-pygments
, lib
, markupsafe
, mistune
, nbclient
, pandocfilters
, pyppeteer
, pytestCheckHook
, tinycss2
}:

buildPythonPackage rec {
  pname = "nbconvert";
    version = "6.5.0";
      format = "setuptools";

  src = fetchPypi {
      inherit pname version;
          hash = "sha256-Ij5G4nq+hZa4rtVDAfrbukM7f/6oGWpo/Xsf9Qnu6Z0=";
            };

  # Add $out/share/jupyter to the list of paths that are used to search for
    # various exporter templates
      patches = [
          ./templates.patch

    # Use mistune 2.x
        (fetchpatch {
              name = "support-mistune-2.x.patch";
                    url = "https://github.com/jupyter/nbconvert/commit/e870d9a4a61432a65bee5466c5fa80c9ee28966e.patch";
                          hash = "sha256-kdOmE7BnkRy2lsNQ2OVrEXXZntJUPJ//b139kSsfKmI=";
                                excludes = [ "pyproject.toml" ];
                                    })
                                      ];

  postPatch = ''
      substituteAllInPlace ./nbconvert/exporters/templateexporter.py
          # Use mistune 2.x
              substituteInPlace setup.py \
                      --replace "mistune>=0.8.1,<2" "mistune>=2.0.3,<3"
                        '';

  propagatedBuildInputs = [
      beautifulsoup4
          bleach
              defusedxml
                  jinja2
                      jupyterlab-pygments
                          markupsafe
                              mistune
                                  nbclient
                                      pandocfilters
                                          tinycss2
                                            ];

  preCheck = ''
      export HOME=$(mktemp -d)
        '';

  checkInputs = [
      ipywidgets
          pyppeteer
              pytestCheckHook
                ];

  pytestFlagsArray = [
      "--ignore=nbconvert/preprocessors/tests/test_execute.py"
          # can't resolve template paths within sandbox
              "--ignore=nbconvert/tests/base.py"
                  "--ignore=nbconvert/tests/test_nbconvertapp.py"
      # DeprecationWarning: Support for bleach <5 will be removed in a future version of nbconvert
          "-W ignore::DeprecationWarning"
            ];

  disabledTests = [
      # Attempts network access (Failed to establish a new connection: [Errno -3] Temporary failure in name resolution)
          "test_export"
              "test_webpdf_with_chromium"
                ];

  # Some of the tests use localhost networking.
    __darwinAllowLocalNetworking = true;

  meta = {
      description = "Converting Jupyter Notebooks";
          homepage = "https://jupyter.org/";
              license = lib.licenses.bsd3;
                  maintainers = with lib.maintainers; [ fridh ];
                    };
                    }