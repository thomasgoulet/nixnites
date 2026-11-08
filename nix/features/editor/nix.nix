{ pkgs, ... }:
{
  home.packages = [
    pkgs.nil
    pkgs.nixd
    pkgs.nixfmt
  ];

  programs.helix.languages.language-server.nixd.command = "nixd";

  programs.helix.languages.language = [
    {
      name = "nix";
      auto-format = true;
      formatter = {
        command = "nixfmt";
      };
    }
  ];
}
