{ ... }:
{
  services.xserver.xkb.options = "caps:escape";
  services.xserver.xkb.layout = "ca";
  console.useXkbConfig = true; # use xkb.options in tty.
}
