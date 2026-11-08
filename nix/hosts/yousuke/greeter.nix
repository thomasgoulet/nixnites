{ pkgs, ... }:
{
  services.displayManager.noctalia-greeter = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    settings = {
      appearance = {
        scheme = "Catppuccin";
        scheme_selector_position = "hidden";
        hide_logo = true;
      };
      output = {
        width = 1920;
        height = 1080;
      };
      cursor.size = 24;
      keyboard.layout = "us";
    };
  };
}
