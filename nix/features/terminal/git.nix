# git, with delta as the pager and diff tool.
{ config, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
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
      blame-palette = "${colors.base00} ${colors.base10} ${colors.base01}";
      hunk-header-style = "omit";
      file-style = "white";
    };
  };
}
