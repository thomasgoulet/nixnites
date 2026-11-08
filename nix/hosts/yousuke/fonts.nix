{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.cascadia-code
      pkgs.inter
      pkgs.lora
      pkgs.nerd-fonts.caskaydia-cove
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "CaskaydiaCove Nerd Font" ];
        sansSerif = [ "Inter" ];
        serif = [ "Lora" ];
      };
    };
  };
}
