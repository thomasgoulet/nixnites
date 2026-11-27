{
  lib,
  pkgs,
  ...
}:
let
  broot-open = pkgs.writeShellApplication {
    name = "broot-open";
    runtimeInputs = [
      pkgs.wezterm
      pkgs.broot
    ];
    text = ''
      arg="''${1:-$HOME}"
      arg="''${arg#file://}"
      arg="$(printf '%b' "''${arg//%/\\x}")"

      if [ -f "$arg" ]; then
        arg="$(dirname "$arg")"
      fi

      exec wezterm start --cwd "$arg" -- broot
    '';
  };
in
{
  xdg.desktopEntries.broot = {
    name = "Broot";
    comment = "Browse directories in a terminal";
    exec = "${lib.getExe broot-open} %u";
    terminal = false;
    noDisplay = true;
    mimeType = [ "inode/directory" ];
    categories = [
      "System"
      "FileTools"
      "FileManager"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "broot.desktop";
  };
}
