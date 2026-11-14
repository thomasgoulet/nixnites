{ config, lib, ... }:
let
  fonts = config.stylix.fonts;
in
{
  programs.wezterm = {
    enable = true;
    settings = {
      window_decorations = "NONE";
      enable_tab_bar = false;
      window_padding = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };
      hyperlink_rules = lib.generators.mkLuaInline "wezterm.default_hyperlink_rules()";
      scroll_to_bottom_on_input = true;

      font = lib.mkForce (
        lib.generators.mkLuaInline "wezterm.font_with_fallback { { family = '${fonts.monospace.name}', weight = 'Medium' }, '${fonts.emoji.name}' }"
      );

      font_rules = [
        {
          intensity = "Half";
          font = lib.generators.mkLuaInline "wezterm.font('${fonts.monospace.name}', { weight = 'Regular' })";
        }
      ];

      default_cursor_style = "SteadyUnderline";
      cursor_thickness = "150%";
      cursor_blink_ease_in = "Constant";
      cursor_blink_ease_out = "Constant";
    };
  };

  stylix.fonts.sizes.terminal = 11;
}
