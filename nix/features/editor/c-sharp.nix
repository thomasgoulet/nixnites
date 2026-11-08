{ pkgs, ... }:
{
  home.packages = [
    pkgs.dotnet-sdk_8
    pkgs.omnisharp-roslyn
  ];

  programs.helix.languages.language-server.omnisharp = {
    command = "OmniSharp";
    args = [ "--languageserver" ];
  };

  programs.helix.languages.language = [
    {
      name = "c-sharp";
      language-servers = [ "omnisharp" ];
    }
  ];
}
