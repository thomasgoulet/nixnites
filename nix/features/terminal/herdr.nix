{ config, ... }:
let
  inherit (config.lib.stylix.colors) withHashtag;
in
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;

      theme = {
        auto_switch = false;
        custom = {
          active_row_bg = withHashtag.base10;
          sidebar_bg = withHashtag.base10;
          surface_dim = withHashtag.base10;
        };
      };

      terminal = {
        default_shell = "nu";
        kitty_graphics = true;
      };

      ui = {
        accent = "white";
        hide_tab_bar_when_single_tab = true;
        host_cursor = "native";
        pane_borders = "auto";
        prompt_new_tab_name = false;
        sidebar_start_collapsed = true;
        status_indicators = "dots";
        tab_bar_position = "bottom";

        toast = {
          delivery = "herdr";
          clipboard.position = "bottom-right";
        };

        sidebar = {
          spaces.row_gap = 1;
          agents = {
            row_gap = 1;
            rows = [
              [
                "state_icon"
                "state_text"
              ]
              [
                {
                  token = "agent";
                  fg = withHashtag.base05;
                  dim = false;
                }
                "workspace"
              ]
            ];
          };
        };
      };

      keys = {
        prefix = "ctrl+space";
        help = [
          "prefix+/"
          "prefix+?"
        ];
        toggle_sidebar = "prefix+space";
        focus_pane_left = "alt+h";
        focus_pane_down = "alt+j";
        focus_pane_up = "alt+k";
        focus_pane_right = "alt+l";
        previous_tab = "alt+shift+h";
        next_tab = "alt+shift+l";
        previous_workspace = "alt+shift+k";
        next_workspace = "alt+shift+j";
        previous_agent = "alt+shift+u";
        next_agent = "alt+shift+n";
        split_vertical = [
          "prefix+v"
          "alt+n"
        ];
        new_tab = "alt+t";
        new_workspace = "alt+w";
        close_pane = "alt+c";
        close_workspace = "alt+q";
        rename_tab = "alt+r";
        rename_workspace = "alt+shift+r";
        move_tab_previous = "prefix+h";
        move_tab_next = "prefix+l";
        zoom = "alt+shift+f";
        goto = "alt+s";
        copy_mode = "prefix+y";
        open_worktree = "prefix+c";
        new_worktree = "prefix+shift+c";
        remove_worktree = "prefix+d";

        command = [
          {
            key = "prefix+f";
            type = "popup";
            command = "nu -c 'with-env { ESCAPE_MODE: float } { nu }'";
            description = "open floating terminal";
            width = "80%";
            height = "80%";
          }
          {
            key = "prefix+g";
            type = "popup";
            command = "drydock";
            description = "open list of repos";
            width = "80%";
          }
          {
            key = "prefix+n";
            type = "popup";
            command = "leaf $ZK_NOTEBOOK_DIR";
            description = "open notes";
            width = "80%";
            height = "80%";
          }
          {
            key = "prefix+t";
            type = "popup";
            command = "tuxedo";
            description = "open tasks";
            width = "80%";
            height = "80%";
          }
        ];
      };

      worktrees.directory = "~/repos/worktrees";
    };
  };
}
