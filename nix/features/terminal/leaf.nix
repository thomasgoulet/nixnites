{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.leaf-markdown-viewer ];

  xdg.configFile."leaf/config.toml" = {
    source = (pkgs.formats.toml { }).generate "leaf-settings.toml" {
      editor = "hx {$path}:{$line}";
      file-history-length = 10;
      theme = "${config.home.homeDirectory}/.config/leaf/theme.toml";
      watch = true;
    };
  };

  xdg.configFile."leaf/theme.toml" = {
    source = (pkgs.formats.toml { }).generate "leaf-theme.toml" {
      base = "ocean";
      markdown = {
        alert_caution = "#f38ba8";
        alert_important = "#f5c2e7";
        alert_note = "#89b4fa";
        alert_tip = "#a6e3a1";
        alert_warning = "#f9e2af";
        blockquote_marker = "#7f849c";
        blockquote_text = "#bac2de";
        code_frame = "#45475a";
        code_gutter = "#45475a";
        code_label = "#7f849c";
        footnote_ref = "#89b4fa";
        footnote_text = "#bac2de";
        heading_1 = "#f38ba8";
        heading_2 = "#fab387";
        heading_3 = "#f9e2af";
        heading_4 = "#a6e3a1";
        heading_other = "#89b4fa";
        heading_underline = "#45475a";
        inline_code_bg = "#313244";
        inline_code_fg = "#fab387";
        latex_block_fg = "#f5c2e7";
        latex_inline_bg = "#313244";
        latex_inline_fg = "#f5c2e7";
        link_hover = "#89dceb";
        link_icon = "#89b4fa";
        link_text = "#89b4fa";
        list_level_1 = "#a6e3a1";
        list_level_2 = "#89b4fa";
        list_level_3 = "#f5c2e7";
        mark_bg = "#585b70";
        mark_fg = "#cdd6f4";
        mermaid_arrow = "#89b4fa";
        mermaid_block_fg = "#cdd6f4";
        mermaid_keyword = "#fab387";
        mermaid_label = "#a6e3a1";
        ordered_list = "#f9e2af";
        rule = "#45475a";
        search_highlight_bg = "#45475a";
        search_match_bg = "#f9e2af";
        strong_text = "#cdd6f4";
        table_border = "#585b70";
        table_cell = "#cdd6f4";
        table_header = "#f9e2af";
        table_separator = "#45475a";
        task_checked = "#a6e3a1";
        task_unchecked = "#7f849c";
        text = "#cdd6f4";
      };
      syntax = "base16-ocean.dark";
      ui = {
        content_bg = "#1e1e2e";
        scrollbar_hover = "#f9e2af";
        status_bg = "#181825";
        status_brand_bg = "#f9e2af";
        status_brand_fg = "#1e1e2e";
        status_error_bg = "#313244";
        status_error_fg = "#f38ba8";
        status_filename_bg = "#313244";
        status_filename_fg = "#cdd6f4";
        status_percent_fg = "#f9e2af";
        status_reloaded_bg = "#a6e3a1";
        status_reloaded_fg = "#1e1e2e";
        status_search_bg = "#313244";
        status_search_fg = "#f9e2af";
        status_separator = "#7f849c";
        status_shortcut_fg = "#7f849c";
        status_success_bg = "#313244";
        status_success_fg = "#a6e3a1";
        status_warning_fg = "#f9e2af";
        status_watch_bg = "#313244";
        status_watch_fg = "#a6e3a1";
        toc_accent = "#fab387";
        toc_active_bg = "#313244";
        toc_bg = "#181825";
        toc_border = "#45475a";
        toc_header_fg = "#7f849c";
        toc_hover_fg = "#f5e0dc";
        toc_inactive_bg = "#181825";
        toc_index_inactive = "#6c7086";
        toc_primary_active = "#cdd6f4";
        toc_primary_inactive = "#bac2de";
        toc_secondary_inactive = "#6c7086";
        toc_secondary_text_active = "#bac2de";
        toc_secondary_text_inactive = "#7f849c";
      };
    };
  };
}
