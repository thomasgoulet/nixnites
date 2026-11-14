{
  pkgs,
  colors,
}:
pkgs.runCommand "koi-wallpaper.png"
  {
    nativeBuildInputs = [
      pkgs.python3
      pkgs.librsvg
    ];
  }
  ''
    python3 ${./.}/generate.py \
      --background '${colors.base00}' \
      --mantle '${colors.base10}' \
      --white '${colors.base07}' \
      --blue '${colors.base0D}' \
      --yellow '${colors.base0A}' \
      --pink '${colors.base0E}' \
      --png $out
  ''
