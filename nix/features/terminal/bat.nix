# bat (https://github.com/sharkdp/bat), the cat clone.
{ ... }:
{
  programs.bat = {
    enable = true;
    config = {
      style = "changes,numbers,header,grid";
      pager = "less -RF --no-init";
    };
  };
}
