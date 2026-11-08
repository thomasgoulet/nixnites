{ pkgs, ... }:
{

  home.packages = [
    pkgs.nodejs_26
    pkgs.prettier
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
  ];

  programs.helix.languages = {
    language-server.vscode-esling-language-server = {
      command = "vscode-eslint-language-server";
      args = [ "stdio" ];
      config = {
        experimental.useFlatConfig = true;
        workingDirectory.mode = "auto";
      };
    };
    language = [
      {
        name = "css";
        auto-format = false;
      }
      {
        name = "html";
        auto-format = false;
      }
      {
        name = "typescript";
        formatter = {
          command = "npx";
          args = [
            "prettier"
            "--parser"
            "typescript"
          ];
        };
        language-servers = [
          "typescript-language-server"
          "vscode-eslint-language-server"
        ];
      }
    ];
  };
}
