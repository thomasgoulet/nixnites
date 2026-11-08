{ ... }:
{
  programs.helix.settings = {
    theme = "catppuccin_mocha";
    editor = {
      bufferline = "always";
      color-modes = true;
      end-of-line-diagnostics = "hint";
      idle-timeout = 0;
      jump-label-alphabet = "hjklvbnmyuiopasdfg";
      line-number = "absolute";
      mouse = false;
      shell = [
        "nu"
        "-c"
      ];
      true-color = true;
      undercurl = true;
      statusline = {
        left = [
          "mode"
          "spinner"
        ];
        center = [
          "file-name"
          "file-modification-indicator"
          "spacer"
          "version-control"
        ];
        right = [
          "register"
          "diagnostics"
          "selections"
          "position"
          "position-percentage"
          "file-encoding"
          "file-line-ending"
          "file-type"
        ];
        separator = "-";
        mode.normal = "NORMAL";
        mode.insert = "INSERT";
        mode.select = "SELECT";
      };
      lsp.display-messages = true;
      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      file-picker.hidden = false;
      auto-pairs = {
        "(" = ")";
        "{" = "}";
        "[" = "]";
        "'" = "'";
        "\"" = "\"";
        "`" = "`";
      };
      soft-wrap.enable = true;
      whitespace = {
        render.tab = "all";
        characters = {
          tab = "→";
          tabpad = "·";
        };
      };
      gutters.layout = [
        "diagnostics"
        "spacer"
        "diff"
        "line-numbers"
        "spacer"
      ];
      indent-guides = {
        character = "|";
        render = true;
      };
      inline-diagnostics.cursor-line = "hint";
    };
    keys.normal = {
      "\\" = "command_palette";
      "esc" = "keep_primary_selection";
      "A-y" = "select_prev_sibling";
      "A-u" = "shrink_selection";
      "A-i" = "expand_selection";
      "A-o" = "select_next_sibling";
      "C-k" = "remove_selections";
      "C-r" = ":redraw";
      "C-s" = "split_selection_on_newline";
      "C-w" = "rotate_view";
      "B" = "extend_prev_word_start";
      "D" = "delete_char_backward";
      "E" = "extend_next_word_end";
      "G" = "goto_word";
      "H" = ":bp";
      "L" = ":bn";
      "S" = "@%s";
      "W" = "extend_next_word_start";
      "y" = [
        "yank"
        ":primary-clipboard-yank"
        ":clipboard-yank"
      ];
      "X" = "extend_line_above";
      "tab" = "jump_backward";
      "S-tab" = "jump_forward";
      space = {
        space = ":wa";
        "B" = ":sh git blame %{buffer_name} -L %{cursor_line},-1 -p";
        "C" = ":bc!";
        "c" = ":bc";
        "F" = "file_picker_in_current_buffer_directory";
        "G" = ":reset-diff-change";
        "q" = ":q";
        "Q" = ":qa!";
        "[" = "jump_view_left";
        "]" = "jump_view_right";
        "," = [
          "save_selection"
          "goto_line_end"
          ":append-output echo ','"
          "collapse_selection"
          "jump_backward"
        ];
        ";" = [
          "save_selection"
          "goto_line_end"
          ":append-output echo ';'"
          "collapse_selection"
          "jump_backward"
        ];
        "tab" = "save_selection";
        t = {
          n = "@o- [ ] ";
          N = "@O- [ ] ";
          d = "@ghf[lrx";
        };
      };
      m = {
        w = "@miw*";
        W = "@miW*";
      };
      "]" = {
        q = "@<space>'<tab><ret>";
      };
      "[" = {
        q = "@<space>'<S-tab><ret>";
      };
      backspace = {
        a = ":sh herdr.nu run tab 0 opencode";
        b = ":sh herdr.nu run tab 0 git blame %{buffer_name}";
        f = ":sh herdr.nu run pane 0.7 broot";
        g = ":sh herdr.nu run pane 0.5 lazygit o> /dev/null";
        p = ":sh herdr.nu run pane 0.5 leaf %{buffer_name} o> /dev/null";
        s = ":sh nix.nu toggle-symlink %{buffer_name}";
        S = ":sh herdr.nu run pane 0.5 nix.nu diff-symlink %{buffer_name}";
      };
    };
  };
}
