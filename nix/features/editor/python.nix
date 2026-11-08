{ inputs', pkgs, ... }:
let
  pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
in
{
  home.packages = [
    pkgs.python312
    pkgs-stable.python312Packages.python-lsp-server
    pkgs-stable.black
    pkgs-stable.ruff
    pkgs-stable.ty
  ];

  programs.helix.languages.language = [
    {
      name = "python";
      auto-format = false;
      indent = {
        tab-width = 4;
        unit = "	";
      };
      formatter = {
        command = "black";
        args = [
          "-"
          "-l160"
        ];
      };
      language-servers = [
        "ruff"
        "pylsp"
      ];
    }
  ];
}
