{
  config,
  lib,
  pkgs,
  ...
}:
let
  zk = (config.programs.zk.enable or false);
in
{
  home.packages = [
    pkgs.harper
    pkgs.marksman
    pkgs.prettier
  ];

  programs.helix.languages.language-server = {
    harper-ls = {
      command = "harper-ls";
      args = [ "--stdio" ];
      config.harper-ls = {
        diagnosticSeverity = "warning";
        dialect = "Canadian";
        linters = {
          SpellCheck = true;
          SpelledNumbers = false;
          AnA = true;
          SentenceCapitalization = true;
          UnclosedQuotes = true;
          WrongApostrophe = true;
          LongSentences = false;
          RepeatedWords = true;
          Spaces = true;
          CorrectNumberSuffix = true;
        };
        markdown.IgnoreLinkTitle = true;
      };
    };
  }
  // lib.optionalAttrs zk {
    zk = {
      command = "zk";
      args = [ "lsp" ];
    };
  };

  programs.helix.languages.language = [
    (
      {
        name = "markdown";
        formatter = {
          command = "prettier";
          args = [
            "--parser"
            "markdown"
          ];
        };
        language-servers = [
          "marksman"
          "harper-ls"
        ];
      }
      // lib.optionalAttrs zk {
        roots = [ ".zk" ];
        language-servers = [
          "marksman"
          "harper-ls"
          "zk"
        ];
      }
    )
  ];

}
