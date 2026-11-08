# git, with delta as the pager and diff tool.
{ ... }:
{
  programs.git.settings = {
    credential.helper = "store";
    push.autoSetupRemote = true;
    diff.colorMoved = "default";
    core.pager = "delta";
    interactive.diffFilter = "delta --color-only";
    merge.conflictstyle = "diff3";

    delta = {
      dark = true;
      line-numbers = true;
      navigate = true;
      side-by-side = true;
      syntax-theme = "Catppuccin Mocha";
      blame-palette = "#1e1e2e #181825 #313244";
      hunk-header-style = "omit";
      file-style = "white";
    };
  };
}
