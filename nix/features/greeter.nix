{ ... }:
{
  den.aspects.greeter = {
    nixos =
      { config, ... }:
      {
        services.displayManager.noctalia-greeter = {
          enable = true;
          cursorTheme = {
            package = config.stylix.cursor.package;
            name = config.stylix.cursor.name;
          };
          settings = {
            appearance = {
              scheme = config.stylix.greeter;
              scheme_selector_position = "hidden";
              hide_logo = true;
            };
            output = {
              name = config.host.display.output;
              use_synced_settings = false;
              width = config.host.display.width;
              height = config.host.display.height;
              refresh_rate = config.host.display.refreshRate;
              scale = config.host.display.scale;
            };
            cursor.size = config.stylix.cursor.size;
            keyboard = {
              layout = config.host.keyboard.layout;
              variant = config.host.keyboard.variant;
              options = config.host.keyboard.options;
            };
          };
        };
      };
  };
}
