{ pkgs, ... }:
{
  home.packages = [
    pkgs.yaml-language-server
    pkgs.yamlfmt
  ];

  programs.helix.languages.language-server.yaml = {
    command = "yaml-language-server";
    args = [ "--stdio" ];
    config.yaml = {
      format.enable = true;
      keyOrdering = false;
    };
  };

  programs.helix.languages.language = [
    {
      name = "yaml";
      file-types = [
        "yaml"
        "yml"
      ];
      language-servers = [ "yaml" ];
      auto-format = false;
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "yaml"
        ];
      };
    }
  ];
}
