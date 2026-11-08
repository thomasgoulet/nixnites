{ pkgs, ... }:
let
  brootShell = pkgs.writeShellScript "broot-shell" ''nu -c "with-env {ESCAPE_MODE: 'file'} {nu}"'';
in
{
  programs.broot = {
    enable = true;
    settings = {
      default_flags = "-g";
      date_time_format = "%Y-%m-%d";
      modal = true;
      initial_mode = "command";
      show_selection_mark = true;
      cols_order = [
        "mark"
        "git"
        "size"
        "permission"
        "date"
        "count"
        "branch"
        "name"
      ];
      special_paths = {
        "~/.config" = {
          show = "always";
        };
        ".azure-devops" = {
          list = "never";
        };
        ".cache" = {
          list = "never";
        };
        ".dotnet" = {
          list = "never";
        };
        ".eclipse" = {
          list = "never";
        };
        ".git" = {
          show = "never";
        };
        ".gradle" = {
          show = "never";
        };
        ".local" = {
          list = "never";
        };
        ".nix" = {
          list = "never";
        };
        ".npm" = {
          list = "never";
        };
        ".nuget" = {
          list = "never";
        };
        ".project" = {
          show = "never";
        };
        ".settings" = {
          show = "never";
        };
        ".venv" = {
          show = "never";
        };
        "automated-tests" = {
          list = "never";
        };
        "bin" = {
          show = "never";
        };
        "build" = {
          show = "never";
        };
        "node_modules" = {
          show = "never";
        };
        "open-api-client" = {
          list = "never";
        };
      };
      quit_on_last_cancel = false;
      search_modes = {
        "<empty>" = "fuzzy path";
        "/" = "regex content";
      };
      enable_kitty_keyboard = false;
      lines_before_match_in_preview = 1;
      lines_after_match_in_preview = 1;
      show_matching_characters_on_path_searches = false;
      preview_transformers = [ ];
      imports = [ ];
      skin = {
        directory = "ansi(4)";
        file = "ansi(15)";
        pruning = "ansi(8) none italic";
        selected_line = "none ansi(8) italic";
        tree = "ansi(8)";
        char_match = "ansi(3) none underlined";
        parent = "ansi(15) none italic";
        exe = "ansi(2)";
        link = "ansi(5)";
        sparse = "ansi(4)";
        input = "ansi(15)";
        status_bold = "ansi(15) none bold";
        status_code = "ansi(10)";
        status_ellipsis = "ansi(15)";
        status_error = "ansi(1) ansi(8)";
        status_italic = "ansi(15) none italic";
        status_job = "ansi(15)";
        status_normal = "ansi(15)";
        flag_label = "ansi(6) none italic";
        flag_value = "ansi(6) none italic";
        default = "none none";
        scrollbar_track = "ansi(0)";
        scrollbar_thumb = "ansi(3)";
        git_branch = "ansi(13)";
        git_deletions = "ansi(1)";
        git_insertions = "ansi(2)";
        git_status_conflicted = "ansi(1)";
        git_status_current = "ansi(6)";
        git_status_ignored = "ansi(8)";
        git_status_modified = "ansi(3)";
        git_status_new = "ansi(2) none bold";
        git_status_other = "ansi(5)";
        staging_area_title = "ansi(3)";
        help_bold = "ansi(7) none bold";
        help_code = "ansi(4)";
        help_headers = "ansi(3)";
        help_italic = "ansi(7) none italic";
        help_paragraph = "ansi(7)";
        help_table_border = "ansi(8)";
        device_id_major = "ansi(5)";
        device_id_minor = "ansi(5)";
        device_id_sep = "ansi(5)";
        count = "ansi(13)";
        dates = "ansi(6)";
        group = "ansi(3)";
        owner = "ansi(3)";
        perm__ = "ansi(8)";
        perm_r = "ansi(3)";
        perm_w = "ansi(1)";
        perm_x = "ansi(2)";
        hex_null = "ansi(8)";
        hex_ascii_graphic = "ansi(2)";
        hex_ascii_whitespace = "ansi(3)";
        hex_ascii_other = "ansi(4)";
        hex_non_ascii = "ansi(5)";
        file_error = "ansi(1)";
        content_extract = "ansi(5)";
        content_match = "ansi(3) none underlined";
        purpose_bold = "ansi(0) ansi(7) bold";
        purpose_ellipsis = "ansi(0)";
        purpose_italic = "ansi(0) ansi(7) italic";
        purpose_normal = "ansi(0)";
        mode_command_mark = "ansi(15) ansi(8)";
        good_to_bad_0 = "ansi(2)";
        good_to_bad_1 = "ansi(2)";
        good_to_bad_2 = "ansi(2)";
        good_to_bad_3 = "ansi(2)";
        good_to_bad_4 = "ansi(2)";
        good_to_bad_5 = "ansi(1)";
        good_to_bad_6 = "ansi(1)";
        good_to_bad_7 = "ansi(1)";
        good_to_bad_8 = "ansi(1)";
        good_to_bad_9 = "ansi(1)";
      };
      verbs = [
        {
          invocation = "quit";
          key = "q";
          internal = ":quit";
          leave_broot = true;
        }
        {
          invocation = "edit";
          shortcut = "e";
          key = "enter";
          apply_to = "text_file";
          execution = "herdr.nu edit {file}:{line}";
          leave_broot = false;
        }
        {
          invocation = "edit";
          shortcut = "e";
          key = "ctrl-e";
          apply_to = "text_file";
          execution = "herdr.nu edit {file}:{line}";
          leave_broot = false;
        }
        {
          name = "touch";
          invocation = "touch {new_file}";
          external = "touch {directory}/{new_file}";
          leave_broot = false;
        }
        {
          invocation = "rm";
          external = "mv {file} ~/.trash";
          leave_broot = false;
        }
        {
          key = "t";
          invocation = "term";
          external = "${brootShell}";
          set_working_dir = true;
          leave_broot = false;
        }
        {
          key = "b";
          invocation = "blame";
          apply_to = "text_file";
          external = "herdr.nu run tab 0 -- git blame {file}";
          set_working_dir = true;
          leave_broot = false;
        }
        {
          key = "d";
          invocation = "diff";
          apply_to = "text_file";
          external = "herdr.nu run tab 0 -- git diff {file}";
          set_working_dir = true;
          leave_broot = false;
        }
        {
          key = "d";
          invocation = "diff";
          apply_to = "directory";
          external = "herdr.nu run tab 0 -- git diff";
          set_working_dir = true;
          leave_broot = false;
        }
      ];
    };
  };
}
