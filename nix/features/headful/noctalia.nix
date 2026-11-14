{ osConfig, ... }:
let
  display = osConfig.host.display;
in
{
  programs.noctalia = {
    enable = true;

    systemd.enable = true;

    settings = {
      accessibility.ui_scale = 1.1;

      bar = {
        order = [ "default" ];

        default = {
          capsule = true;
          capsule_radius = 4;
          center = [ "workspaces" ];
          end = [
            "tray"
            "clipboard"
            "screenshot"
            "theme_mode"
            "spacer_1"
            "notifications"
            "network"
            "spacer_2"
            "keyboard_layout"
            "volume"
            "brightness"
            "battery"
            "spacer_3"
            "session"
          ];
          margin_ends = 0;
          padding = 8;
          position = "bottom";
          radius = 4;
          start = [
            "launcher"
            "custom_button_2"
            "clock"
            "date"
          ];
          thickness = 40;

          dead_zone.actions = {
            left = "panel-toggle control-center home";
            right = "panel-toggle control-center media";
          };
        };
      };

      battery.warning_threshold = 15;

      control_center = {
        show_shortcut_labels = false;
        sidebar = "full";
        sidebar_section = "full";
        shortcuts = [
          { type = "wifi"; }
          { type = "bluetooth"; }
          { type = "audio"; }
          { type = "clipboard"; }
          { type = "keyboard_layout"; }
          { type = "session"; }
        ];
      };

      idle = {
        behavior_order = [
          "Bitwarden Lock"
          "lock"
          "screen-off"
          "lock-and-suspend"
        ];
        pre_action_fade_seconds = 0;

        behavior = {
          "Bitwarden Lock" = {
            action = "command";
            command = "curl localhost:8087/lock";
            enabled = true;
            timeout = 30.0;
          };

          lock.enabled = true;

          lock-and-suspend.enabled = true;

          screen-off.enabled = true;
        };
      };

      lockscreen.blur_intensity = 0.15;

      lockscreen_widgets = {
        enabled = true;
        widget_order = [
          "lockscreen-login-box@${display.output}"
          "lockscreen-widget-0000000000000001"
          "lockscreen-widget-0000000000000002"
        ];

        widget = {
          "lockscreen-login-box@${display.output}" = {
            box_height = 128.0;
            box_width = 720.0;
            cx = 448.0;
            cy = 476.0;
            output = display.output;
            placement_height = display.height * 1.0;
            placement_width = display.width * 1.0;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_container";
              background_opacity = 1.0;
              background_radius = 12.0;
              center_password_text = true;
              input_opacity = 1.0;
              input_radius = 4.0;
              layout = "regular";
              show_caps_lock = false;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = false;
              show_session_buttons = true;
              show_unlock_hint = false;
              show_weather = false;
            };
          };

          lockscreen-widget-0000000000000001 = {
            box_height = 128.0;
            box_width = 384.0;
            cx = 448.0;
            cy = 316.0;
            output = display.output;
            placement_height = display.height * 1.0;
            placement_width = display.width * 1.0;
            rotation = 0.0;
            type = "clock";

            settings = {
              background = true;
              center_text = false;
              clock_style = "digital";
              color = "on_surface";
              format = "{:%H:%M:%S}";
              timezone = "";
            };
          };

          lockscreen-widget-0000000000000002 = {
            box_height = 384.0;
            box_width = 384.0;
            cx = 448.0;
            cy = 764.0;
            output = display.output;
            placement_height = display.height * 1.0;
            placement_width = display.width * 1.0;
            rotation = 0.0;
            type = "calendar";

            settings = {
              background = true;
              show_events = false;
              show_week_numbers = false;
            };
          };
        };
      };

      plugins.enabled = [ "noctalia/bitwarden" ];

      shell = {
        button_borders = false;
        card_borders = false;
        clipboard_history_max_entries = 10;
        corner_radius_scale = 0.5;
        input_borders = false;
        launch_apps_as_systemd_services = true;
        polkit_agent = true;
        popup_borders = false;
        time_format = "{:%H:%M:%S}";
        umbriel_overview_close_on_launch_enabled = true;
        umbriel_overview_type_to_launch_enabled = true;

        animation.speed = 1.5;

        keyboard_layout.custom_labels = {
          "English (Canada)" = "EN";
          "French (Canada)" = "FR";
        };

        launcher = {
          categories = false;
          fetch_exchange_rates = false;
          show_app_actions = true;
          show_icons = false;

          providers = {
            session.global = true;
            windows.global = true;
          };
        };

        panel = {
          borders = false;
          control_center_placement = "floating";
          open_near_click_control_center = true;
          session_placement = "floating";
          session_position = "center";
          wallpaper_placement = "floating";
        };

        screen_corners = {
          enabled = true;
          size = 4;
        };

        session = {
          grid = true;
          grid_columns = 2;
          show_shortcuts = false;
        };

        shadow.direction = "down_right";
      };

      system.monitor.enabled = false;

      wallpaper = {
        directory = "${../../../resources/wallpaper}";
        fill_color = "on_primary";
        transition_on_startup = true;
      };

      widget = {
        clock = {
          capsule = true;
          capsule_fill = "primary";
          capsule_foreground = "on_primary";
          format = "{:%H:%M:%S}";
        };

        custom_button_2 = {
          glyph = "terminal";
          tooltip = "Terminal";
          type = "custom_button";

          actions = {
            left = "exec alacritty";
            middle = "none";
          };
        };

        date = {
          capsule_radius = 4;
          format = "{:%y-%m-%d}";
        };

        media.hide_when_no_media = true;

        network.show_label = false;

        spacer_1.type = "spacer";
        spacer_2.type = "spacer";
        spacer_3.type = "spacer";

        taskbar = {
          colorize_icons = true;
          only_active_workspace = true;
        };

        workspaces = {
          active_pill_size = 2.0;
          capsule = true;
          capsule_fill = "surface";
          focused_color = "primary";
          occupied_color = "secondary";
          pill_scale = 0.5;
          scale = 1.5;
          show_labels = false;
          style = "regular";
        };
      };
    };
  };
}
