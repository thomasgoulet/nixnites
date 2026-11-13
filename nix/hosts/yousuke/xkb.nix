{ config, ... }:
{
  host.keyboard = {
    layout = "ca,ca";
    variant = "eng,fr";
    options = "caps:escape,grp:win_space_toggle";
  };

  services.xserver.xkb = {
    inherit (config.host.keyboard) layout variant options;
  };
  console.useXkbConfig = true; # use xkb.options in tty.
}
