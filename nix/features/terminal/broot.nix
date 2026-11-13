{ pkgs, ... }:
let
  brootShell = pkgs.writeShellScript "broot-shell" ''nu -c "with-env {ESCAPE_MODE: 'broot'} {nu}"'';
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
