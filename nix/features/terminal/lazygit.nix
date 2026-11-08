{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      customCommands = [
        {
          command = "git pull --prune";
          context = "localBranches";
          key = "C";
        }
      ];
      git.branchLogCmd = ''git log --pretty=format:"%C(brightwhite)%s%Creset%n%C(yellow)%ar%Creset - %C(cyan)%ae%Creset%n" --color=always --stat --'';
      gui = {
        border = "single";
        showBottomLine = false;
        showFileIcons = false;
        showPanelJumps = false;
        showRandomTip = false;
        sidePanels = [
          [
            "files"
            "worktrees"
            "status"
          ]
          [
            "branches"
            "remotes"
            "tags"
          ]
          [
            "commits"
            "reflog"
            "stash"
          ]
        ];
        statusPanelView = "allBranchesLog";
        theme = {
          activeBorderColor = [
            "blue"
            "bold"
          ];
          inactiveBorderColor = [
            "white"
            "bold"
          ];
          selectedLineBgColor = [ "#3e4452" ];
        };
        timeFormat = "2006-01-02 / 15h04m";
      };
      notARepository = "skip";
      os = {
        edit = "hx {{filename}}";
        editAtLine = "hx +{{line}} {{filename}}";
        editInTerminal = true;
        openDirInEditor = "hx {{dir}}";
        open = "herdr.nu edit {{filename}}";
        openLink = "wsl-open {{link}}";
      };
    };
  };
}
