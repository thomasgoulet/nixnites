{ pkgs, ... }:
{
  stylix.targets.font-packages.enable = true;

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
      defaultFonts.serif = [ "Lora" ];
    };
  };
}
