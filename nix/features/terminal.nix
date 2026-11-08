{
  den,
  inputs,
  ...
}:
{
  den.aspects.terminal = {

    includes = [
      den.aspects.editor
      den.aspects.nushell
    ];

    homeManager =
      {
        pkgs,
        ...
      }:
      {
        imports = [
          (inputs.import-tree ./terminal)
        ];

        home.packages = [

          # Core functionality
          pkgs.carapace
          pkgs.herdr

          # General utilities
          pkgs.delta
          pkgs.eza
          pkgs.fd
          pkgs.fzf
          pkgs.just
          pkgs.jq
          pkgs.nh
          pkgs.ripgrep
          pkgs.sd
          pkgs.zoxide
        ];
      };
  };
}
