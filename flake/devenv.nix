{ pkgs, contents }:

with pkgs;
with lib;

let fc = 
      if (builtins.elem fontconfig contents) then
        [ (fontconfig.override {
          dejavu_fonts = dejavu_fonts // { minimal = dejavu_fonts; };
        }) ]
      else
        [];
in                   

let shellHook =
      if fc != [] then
        ''        
        export FONTCONFIG_FILE=${(head fc).out}/etc/fonts/fonts.conf
        export NIX_DEV_ENV=yes
        ''   
      else
        ''
        export NIX_DEV_ENV=yes
        '';
in
                               
let contents_no_fc = filter (p : p != fontconfig) contents;
in


pkgs.mkShell {
  buildInputs = contents_no_fc ++ fc;
  inherit shellHook;
}