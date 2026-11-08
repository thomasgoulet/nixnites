# starship (https://starship.rs), the shell prompt.
{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = ''
        $cmd_duration [$directory](bright-white)$kubernetes$azure$git_status
        $env_var$character'';

      cmd_duration = {
        format = "[ took $duration]($style)\n\n";
        style = "italic white";
        min_time = 2000;
      };

      env_var.ESCAPE_MODE = {
        style = "italic purple";
        variable = "ESCAPE_MODE";
        format = "[ $env_value]($style)";
      };
      character = {
        success_symbol = " [->](bright-white)";
        error_symbol = " [|>](red)";
      };
      directory = {
        style = "blue";
        format = "[$path]($style)";
        fish_style_pwd_dir_length = 1;
      };

      kubernetes = {
        style = "green";
        format = " [\\[[[k8s::](bright-white)$context([:](bright-white)[$namespace](yellow))]($style)\\]](bright-white)";
        disabled = false;
        contexts = [
          {
            context_pattern = ".*prod.*";
            style = "red";
          }
        ];
      };
      git_status = {
        style = "red";
        deleted = "x";
        diverged = "[⇡⇣](purple)";
        up_to_date = "[](green)";
        format = " [\\[[$all_status$ahead_behind]($style)\\]](bright-white)";
      };
    };
  };
}
