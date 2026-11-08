{ pkgs, ... }: {
  home.packages = [ pkgs.nushell ];

  programs.helix.languages.language = [
    {
      name = "nu";
      indent = {
        tab-width = 4;
        unit = "    ";
      };
    }
  ];
}
