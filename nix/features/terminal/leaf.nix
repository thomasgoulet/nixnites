{
  config,
  pkgs,
  ...
}:
let
  colors = config.lib.stylix.colors.withHashtag;
in
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
        alert_caution = colors.base08;
        alert_important = colors.base0E;
        alert_note = colors.base0D;
        alert_tip = colors.base0B;
        alert_warning = colors.base0A;
        blockquote_marker = colors.base03;
        blockquote_text = colors.base04;
        code_frame = colors.base02;
        code_gutter = colors.base02;
        code_label = colors.base03;
        footnote_ref = colors.base0D;
        footnote_text = colors.base04;
        heading_1 = colors.base08;
        heading_2 = colors.base09;
        heading_3 = colors.base0A;
        heading_4 = colors.base0B;
        heading_other = colors.base0D;
        heading_underline = colors.base02;
        inline_code_bg = colors.base01;
        inline_code_fg = colors.base09;
        latex_block_fg = colors.base0E;
        latex_inline_bg = colors.base01;
        latex_inline_fg = colors.base0E;
        link_hover = colors.base0C;
        link_icon = colors.base0D;
        link_text = colors.base0D;
        list_level_1 = colors.base0B;
        list_level_2 = colors.base0D;
        list_level_3 = colors.base0E;
        mark_bg = colors.base03;
        mark_fg = colors.base05;
        mermaid_arrow = colors.base0D;
        mermaid_block_fg = colors.base05;
        mermaid_keyword = colors.base09;
        mermaid_label = colors.base0B;
        ordered_list = colors.base0A;
        rule = colors.base02;
        search_highlight_bg = colors.base02;
        search_match_bg = colors.base0A;
        strong_text = colors.base05;
        table_border = colors.base03;
        table_cell = colors.base05;
        table_header = colors.base0A;
        table_separator = colors.base02;
        task_checked = colors.base0B;
        task_unchecked = colors.base03;
        text = colors.base05;
      };
      syntax = "base16-ocean.dark";
      ui = {
        content_bg = colors.base00;
        scrollbar_hover = colors.base0A;
        status_bg = colors.base10;
        status_brand_bg = colors.base0A;
        status_brand_fg = colors.base00;
        status_error_bg = colors.base01;
        status_error_fg = colors.base08;
        status_filename_bg = colors.base01;
        status_filename_fg = colors.base05;
        status_percent_fg = colors.base0A;
        status_reloaded_bg = colors.base0B;
        status_reloaded_fg = colors.base00;
        status_search_bg = colors.base01;
        status_search_fg = colors.base0A;
        status_separator = colors.base03;
        status_shortcut_fg = colors.base03;
        status_success_bg = colors.base01;
        status_success_fg = colors.base0B;
        status_warning_fg = colors.base0A;
        status_watch_bg = colors.base01;
        status_watch_fg = colors.base0B;
        toc_accent = colors.base09;
        toc_active_bg = colors.base01;
        toc_bg = colors.base10;
        toc_border = colors.base02;
        toc_header_fg = colors.base03;
        toc_hover_fg = colors.base06;
        toc_inactive_bg = colors.base10;
        toc_index_inactive = colors.base03;
        toc_primary_active = colors.base05;
        toc_primary_inactive = colors.base04;
        toc_secondary_inactive = colors.base03;
        toc_secondary_text_active = colors.base04;
        toc_secondary_text_inactive = colors.base03;
      };
    };
  };
}
