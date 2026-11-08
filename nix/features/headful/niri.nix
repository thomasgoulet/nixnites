{ pkgs, ... }:
{
  home.packages = [
    pkgs.bibata-cursors
    pkgs.playerctl
  ];

  programs.niri = {

    settings = {
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
      };

      input = {
        keyboard.xkb = {
          options = "caps:escape,grp:win_space_toggle";
          layout = "ca,ca";
          variant = "eng,fr";
        };

        touchpad = {
          tap = true;
          middle-emulation = true;
          natural-scroll = true;
          accel-speed = 0.2;
        };

        focus-follows-mouse = {
          enable = false;
        };
      };

      outputs."eDP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.003;
        };
        scale = 1;
        transform = {
          rotation = 0;
          flipped = false;
        };
        position = {
          x = 0;
          y = 0;
        };
      };

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

        "Mod+T" = {
          hotkey-overlay.title = "Open a Terminal: alacritty";
          action.spawn = "alacritty";
        };
        "Mod+D" = {
          hotkey-overlay.title = "Run an Application";
          action.spawn-sh = "noctalia msg panel-toggle launcher";
        };
        "Super+Escape" = {
          hotkey-overlay.title = "Lock the Screen";
          action.spawn = [
            "noctalia"
            "msg"
            "session"
            "lock"
          ];
        };

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl play-pause";
        };
        "XF86AudioPause" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl play-pause";
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl next";
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl previous";
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl stop";
        };

        "Mod+O" = {
          repeat = false;
          action.toggle-overview = [ ];
        };
        "Mod+Q" = {
          repeat = false;
          action.close-window = [ ];
        };

        "Mod+H".action.focus-column-left = [ ];
        "Mod+L".action.focus-column-right = [ ];
        "Mod+Ctrl+H".action.move-column-left = [ ];
        "Mod+Ctrl+L".action.move-column-right = [ ];
        "Mod+J".action.focus-window-or-workspace-down = [ ];
        "Mod+K".action.focus-window-or-workspace-up = [ ];
        "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = [ ];
        "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = [ ];
        "Mod+Shift+H".action.focus-monitor-left = [ ];
        "Mod+Shift+L".action.focus-monitor-right = [ ];
        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
        "Mod+Shift+J".action.move-workspace-down = [ ];
        "Mod+Shift+K".action.move-workspace-up = [ ];

        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-workspace-down = [ ];
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-workspace-up = [ ];
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-down = [ ];
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-up = [ ];
        };

        "Mod+WheelScrollRight".action.focus-column-right = [ ];
        "Mod+WheelScrollLeft".action.focus-column-left = [ ];
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];
        "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
        "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Ctrl+1".action.move-window-to-workspace = 1;
        "Mod+Ctrl+2".action.move-window-to-workspace = 2;
        "Mod+Ctrl+3".action.move-window-to-workspace = 3;
        "Mod+Ctrl+4".action.move-window-to-workspace = 4;
        "Mod+Ctrl+5".action.move-window-to-workspace = 5;
        "Mod+Ctrl+6".action.move-window-to-workspace = 6;
        "Mod+Ctrl+7".action.move-window-to-workspace = 7;
        "Mod+Ctrl+8".action.move-window-to-workspace = 8;
        "Mod+Ctrl+9".action.move-window-to-workspace = 9;

        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];
        "Mod+W".action.toggle-column-tabbed-display = [ ];
        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Ctrl+R".action.reset-window-height = [ ];
        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];
        "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
        "Mod+C".action.center-column = [ ];
        "Mod+Ctrl+C".action.center-visible-columns = [ ];
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";
        "Mod+V".action.toggle-window-floating = [ ];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];
        "Print".action.screenshot = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];
        "Mod+Shift+E".action.quit = [ ];
        "Ctrl+Alt+Delete".action.quit = [ ];
        "Mod+Shift+P".action.power-off-monitors = [ ];
      };

      switch-events.lid-close.action.spawn = [
        "noctalia"
        "msg"
        "session"
        "lock"
      ];

      overview = {
        backdrop-color = "#1e1e2e";
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        default-column-width.proportion = 1.0;
        preset-column-widths = [
          { proportion = 1.0; }
          { proportion = 0.75; }
          { proportion = 0.66667; }
          { proportion = 0.5; }
          { proportion = 0.33333; }
        ];

        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#45475a";
        };

        border.enable = false;

        shadow = {
          enable = true;
          draw-behind-window = true;
          softness = 30;
          spread = 10;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#0007";
        };

        struts = {
          left = 8;
          right = 12;
          top = 4;
          bottom = 4;
        };
      };

      spawn-at-startup = [
        { argv = [ "noctalia" ]; }
      ];

      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      window-rules = [
        {
          matches = [
            {
              app-id = "^org\\.wezfurlong\\.wezterm$";
            }
          ];
          default-column-width = { };
        }
        {
          geometry-corner-radius = {
            top-left = 4.0;
            top-right = 4.0;
            bottom-left = 4.0;
            bottom-right = 4.0;
          };
          clip-to-geometry = true;
        }
      ];
    };
  };
}
