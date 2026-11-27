{
  pkgs ? import (import ../.tack { }).nixpkgs { },
  lib ? pkgs.lib,
  nh ? pkgs.nh,
  nix ? pkgs.nix,
  tack ? (import ../.tack { }).tack.packages.${pkgs.stdenv.hostPlatform.system}.default,
}:
let

  dependencies = lib.makeBinPath [
    nh
    nix
    tack
  ];

  script =
    ''$env.PATH = ($env.PATH | prepend ("${dependencies}" | split row ":"))''
    + "\n"
    + builtins.readFile ./nites.nu;

in
pkgs.writers.writeNuBin "nites" script
