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
            theme = "Catppuccin Mocha";
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

        xdg.configFile."tuxedo/themes/catpuccin.toml" = {
          source = (pkgs.formats.toml { }).generate "tuxedo-catppuccin.toml" {
            name = "Catppuccin Mocha";
            bg = "#1E1E2E";
            panel = "#181825";
            border = "#45475A";
            fg = "#CDD6F4";
            dim = "#7F849C";
            accent = "#89B4FA";
            cursor = "#313244";
            selection = "#313244";
            selected = "#313244";
            statusbar = "#181825";
            status_fg = "#BAC2DE";
            mode_fg = "#1E1E2E";
            mode_bg = "#89B4FA";
            pri_a = "#F38BA8";
            pri_b = "#FAB387";
            pri_c = "#A6E3A1";
            pri_d = "#89B4FA";
            pri_other = "#CBA6F7";
            project = "#CBA6F7";
            context = "#94E2D5";
            done = "#A6ADC8";
            matched = "#F9E2AF";
            due = "#F9E2AF";
            overdue = "#F38BA8";
            today = "#F38BA8";
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
