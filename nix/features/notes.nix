# Note taking with zk (https://zk-org.github.io/zk).
{ den, ... }:
{
  den.aspects.notes = {

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        colors = config.lib.stylix.colors.withHashtag;
      in
      {
        home.packages = [
          pkgs.fzf
          pkgs.tuxedo
        ];

        home.sessionVariables = {
          TODO_DIR = "${config.home.homeDirectory}/notebook";
          TODO_FILE = "${config.home.homeDirectory}/notebook/tasks.txt";
          ZK_NOTEBOOK_DIR = "${config.home.homeDirectory}/notebook";
          ZK_SHELL = "/bin/bash";
        };

        xdg.configFile."tuxedo/config.toml" = {
          source = (pkgs.formats.toml { }).generate "tuxedo-config.toml" {
            theme = "Stylix";
            density = "cozy";
            sort = "priority";
            show_left = true;
            show_right = false;
            show_line_num = true;
            show_status_bar = true;
            show_done = true;
            show_future = false;
          };
          force = true;
        };

        xdg.configFile."tuxedo/themes/stylix.toml" = {
          source = (pkgs.formats.toml { }).generate "tuxedo-stylix.toml" {
            name = "Stylix";
            bg = colors.base00;
            panel = colors.base10;
            border = colors.base02;
            fg = colors.base05;
            dim = colors.base03;
            accent = colors.base0D;
            cursor = colors.base01;
            selection = colors.base01;
            selected = colors.base01;
            statusbar = colors.base10;
            status_fg = colors.base04;
            mode_fg = colors.base00;
            mode_bg = colors.base0D;
            pri_a = colors.base08;
            pri_b = colors.base09;
            pri_c = colors.base0B;
            pri_d = colors.base0D;
            pri_other = colors.base0E;
            project = colors.base0E;
            context = colors.base0C;
            done = colors.base04;
            matched = colors.base0A;
            due = colors.base0A;
            overdue = colors.base08;
            today = colors.base08;
          };
        };

        # zk's paging and fzf preview uses bat
        programs.bat.enable = true;

        programs.zk = {
          enable = true;
          settings = {
            note = {
              language = "en";
              default-title = "untitled";
              filename = "{{format-date now '%Y-%m-%d'}}-{{slug title}}";
              template = "default.md";
              exclude = [ "drafts/*" ];
              id-charset = "numbers";
              id-length = 5;
            };

            extra = {
              id = "{{id}}";
            };

            format.markdown = {
              link-format = "wiki";
              hashtags = true;
              colon-tags = true;
              multiword-tags = false;
            };

            tool = {
              pager = "less -FIRX";
              fzf-preview = "bat -p --color always {-1}";
            };

            lsp.diagnostics = {
              wiki-title = "none";
              dead-link = "error";
              self-link = "error";
              missing-backlink = {
                level = "hint";
                position = "bottom";
              };
            };

            alias = {
              config = "hx $ZK_NOTEBOOK_DIR/.zk/config.toml ~/.config/zk/config.toml";
              e = "zk edit -i $@";
              last = "zk edit --limit 1 --sort modified- $@";
              list = "zk list -q -f oneline $@";
            };
          };
        };
      };
  };
}
