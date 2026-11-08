{ pkgs, ... }:
{
  xdg.configFile."hl/config.toml" = {
    source = (pkgs.formats.toml { }).generate "hl-settings.toml" {
      fields = {
        hide = [
          "ecs.version"
          "process.pid"
          "process.thread"
          "service.name"
        ];
        predefined = {
          level.variants = [
            {
              names = [
                "level"
                "LEVEL"
                "Level"
                "log.level"
              ];
              values = {
                debug = [ "debug" ];
                error = [
                  "error"
                  "err"
                  "fatal"
                  "critical"
                  "panic"
                ];
                info = [
                  "info"
                  "information"
                ];
                trace = [ "trace" ];
                warning = [
                  "warning"
                  "warn"
                ];
              };
            }
            {
              names = [ "PRIORITY" ];
              values = {
                debug = [ 7 ];
                error = [
                  3
                  2
                  1
                ];
                info = [ 6 ];
                warning = [
                  5
                  4
                ];
              };
            }
          ];
          logger.names = [
            "logger"
            "LOGGER"
            "Logger"
            "span.name"
            "log.logger"
          ];
        };
      };
      pager.candidates = [
        {
          env = {
            delimiter = "HL_PAGER_DELIMITER";
            follow = "HL_FOLLOW_PAGER";
            pager = "HL_PAGER";
          };
          profiles = true;
        }
        { env = "PAGER"; }
        { profile = "less"; }
      ];
      theme = "classic-plus";
      time-format = "%m-%d %T.%3N";
    };
  };
}
