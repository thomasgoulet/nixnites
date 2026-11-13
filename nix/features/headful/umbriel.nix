{ config, osConfig, pkgs, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
  inherit (osConfig.host) display keyboard;
in
{
  home.packages = [
    pkgs.bibata-cursors
    pkgs.playerctl
  ];

  programs.umbriel = {
    enable = true;

    settings = {
      general = {
        autostart = [ ];
        show_cheatsheet = false;
      };

      input = {
        keyboard = {
          layout = keyboard.layout;
          variant = keyboard.variant;
          options = keyboard.options;
        };

        touchpad = {
          tap = true;
          natural_scroll = true;
          sensitivity = 0.2;
        };

        focus.follows_mouse = "off";

        cursor = {
          theme = "Bibata-Modern-Classic";
          size = 24;
        };
      };

      output.${display.output} = {
        mode = "${toString display.width}x${toString display.height}@${toString display.refreshRate}";
        scale = display.scale;
        transform = "normal";
        position = [
          0
          0
        ];
      };

      layout = {
        gap = 8;
        extent_presets = [
          1.0
          0.75
          0.66667
          0.5
          0.33333
        ];
        struts = {
          left = 8;
          right = 12;
          top = 4;
          bottom = 4;
        };
        scrolling = {
          default_extent_fraction = 1.0;
          center_focused = "never";
        };
      };

      appearance = {
        border_width = 2;
        corner_radius = 4;
        shadow = {
          enabled = true;
          softness = 30;
          offset_x = 0;
          offset_y = 5;
        };
      };

      colors = {
        shadow = "#00000077";
        border = {
          focused = "#45475aFF";
          unfocused = "#00000000";
        };
        overview.background_tint = "#1e1e2eFF";
      };

      events.lid_close = "noctalia msg session lock";

      keybinds = {
        "Mod+T" = "spawn alacritty";
        "Mod+D" = "spawn noctalia msg panel-toggle launcher";
        "Super+Escape" = "spawn noctalia msg session lock";

        "XF86AudioRaiseVolume" = {
          action = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+";
          allow_when_locked = true;
        };
        "XF86AudioLowerVolume" = {
          action = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
          allow_when_locked = true;
        };
        "XF86AudioMute" = {
          action = "spawn wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          allow_when_locked = true;
          repeat = false;
        };
        "XF86AudioMicMute" = {
          action = "spawn wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          allow_when_locked = true;
          repeat = false;
        };
        "XF86AudioPlay" = {
          action = "spawn playerctl play-pause";
          allow_when_locked = true;
        };
        "XF86AudioPause" = {
          action = "spawn playerctl play-pause";
          allow_when_locked = true;
        };
        "XF86AudioNext" = {
          action = "spawn playerctl next";
          allow_when_locked = true;
        };
        "XF86AudioPrev" = {
          action = "spawn playerctl previous";
          allow_when_locked = true;
        };
        "XF86AudioStop" = {
          action = "spawn playerctl stop";
          allow_when_locked = true;
        };

        "Print" = "spawn noctalia msg screenshot-region";
        "Ctrl+Print" = "spawn noctalia msg screenshot-fullscreen";
        "Alt+Print" = "spawn noctalia msg screenshot-window";

        "Mod+O" = {
          action = "overview-toggle";
          repeat = false;
        };
        "Mod+Q" = {
          action = "window-close";
          repeat = false;
        };

        "Mod+H" = "window-focus-left";
        "Mod+L" = "window-focus-right";
        "Mod+J" = "window-focus-or-workspace-down";
        "Mod+K" = "window-focus-or-workspace-up";
        "Mod+Ctrl+H" = "column-move-left";
        "Mod+Ctrl+L" = "column-move-right";
        "Mod+Ctrl+J" = "window-move-or-workspace-down";
        "Mod+Ctrl+K" = "window-move-or-workspace-up";
        "Mod+Shift+H" = "output-focus-left";
        "Mod+Shift+L" = "output-focus-right";
        "Mod+Shift+Ctrl+H" = "column-move-to-output-left";
        "Mod+Shift+Ctrl+J" = "column-move-to-output-down";
        "Mod+Shift+Ctrl+K" = "column-move-to-output-up";
        "Mod+Shift+Ctrl+L" = "column-move-to-output-right";
        "Mod+Shift+J" = "workspace-move-down";
        "Mod+Shift+K" = "workspace-move-up";

        "Mod+WheelDown" = {
          action = "workspace-next";
          cooldown_ms = 150;
        };
        "Mod+WheelUp" = {
          action = "workspace-previous";
          cooldown_ms = 150;
        };
        "Mod+Ctrl+WheelDown" = {
          action = "column-move-to-workspace-next";
          cooldown_ms = 150;
        };
        "Mod+Ctrl+WheelUp" = {
          action = "column-move-to-workspace-previous";
          cooldown_ms = 150;
        };
        "Mod+WheelRight" = "window-focus-right";
        "Mod+WheelLeft" = "window-focus-left";
        "Mod+Ctrl+WheelRight" = "column-move-right";
        "Mod+Ctrl+WheelLeft" = "column-move-left";
        "Mod+Shift+WheelDown" = "window-focus-right";
        "Mod+Shift+WheelUp" = "window-focus-left";
        "Mod+Ctrl+Shift+WheelDown" = "column-move-right";
        "Mod+Ctrl+Shift+WheelUp" = "column-move-left";

        "Mod+1" = "workspace-switch 1";
        "Mod+2" = "workspace-switch 2";
        "Mod+3" = "workspace-switch 3";
        "Mod+4" = "workspace-switch 4";
        "Mod+5" = "workspace-switch 5";
        "Mod+6" = "workspace-switch 6";
        "Mod+7" = "workspace-switch 7";
        "Mod+8" = "workspace-switch 8";
        "Mod+9" = "workspace-switch 9";
        "Mod+Ctrl+1" = "window-move-to-workspace 1";
        "Mod+Ctrl+2" = "window-move-to-workspace 2";
        "Mod+Ctrl+3" = "window-move-to-workspace 3";
        "Mod+Ctrl+4" = "window-move-to-workspace 4";
        "Mod+Ctrl+5" = "window-move-to-workspace 5";
        "Mod+Ctrl+6" = "window-move-to-workspace 6";
        "Mod+Ctrl+7" = "window-move-to-workspace 7";
        "Mod+Ctrl+8" = "window-move-to-workspace 8";
        "Mod+Ctrl+9" = "window-move-to-workspace 9";

        "Mod+BracketLeft" = "window-consume-or-expel-left";
        "Mod+BracketRight" = "window-consume-or-expel-right";
        "Mod+Comma" = "window-consume-from-right";
        "Mod+W" = "column-toggle-tabbed";
        "Mod+R" = "window-cycle-primary-extent";
        "Mod+Shift+R" = "window-cycle-secondary-extent";
        "Mod+F" = "window-toggle-maximize";
        "Mod+Shift+F" = "window-toggle-fullscreen";
        "Mod+C" = "column-center";
        "Mod+Minus" = "window-modify-primary-extent -0.1";
        "Mod+Equal" = "window-modify-primary-extent +0.1";
        "Mod+Shift+Minus" = "window-modify-secondary-extent -0.1";
        "Mod+Shift+Equal" = "window-modify-secondary-extent +0.1";
        "Mod+V" = "window-toggle-floating";
        "Mod+Shift+V" = "window-focus-switch-floating";

        "Mod+Shift+E" = "session-quit";
        "Ctrl+Alt+Delete" = "session-quit";
        "Mod+Shift+P" = "dpms-off";
      };
    };
  };
}
