{ pkgs, ... }:
{
  home.packages = [
    pkgs.go
    pkgs.gopls
  ];
}
