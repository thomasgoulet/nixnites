{ config, pkgs, ... }:
{
  wsl = {
    useWindowsDriver = true;
    startMenuLaunchers = true;
    wslConf.automount.options = "metadata,noatime,uid=1000,gid=100";
  };

  environment.systemPackages = [
    pkgs.nh
    pkgs.wsl-open
  ];

  environment.variables = {
    BROWSER = "wsl-open";
    NH_HOST = config.networking.hostName;
  };

  programs.nix-ld.enable = true;

  nix.settings.trusted-users = [
    "root"
    "thomas"
  ];
}
