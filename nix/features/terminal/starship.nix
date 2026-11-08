# starship (https://starship.rs), the shell prompt.
{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        error_symbol = " [::](red)";
        success_symbol = " [::](bright-white)";
      };
      cmd_duration = {
        format = "[ took $duration]($style)\n\n";
        min_time = 2000;
        style = "italic white";
      };
      directory = {
        fish_style_pwd_dir_length = 1;
        format = "[cwd::](white)[$path]($style)";
        style = "blue";
        truncation_length = 2;
      };
      env_var = {
        ESCAPE_MODE = {
          format = "\n esc::[$env_value]($style)";
          style = "purple";
          variable = "ESCAPE_MODE";
        };
      };
      format = ''
        $cmd_duration [$directory](white)$git_branch$git_status$git_metrics$kubernetes$terraform$nodejs$env_var
        $character'';
      git_branch = {
        format = "\n git::[$branch]($style)(white)";
        style = "yellow";
      };
      git_metrics = {
        added_style = "green dimmed";
        deleted_style = "red dimmed";
        disabled = false;
        format = "[:](dimmed)[+$added]($added_style)[-$deleted]($deleted_style)";
        only_nonzero_diffs = true;
      };
      git_status = {
        deleted = "x";
        diverged = "⇡⇣";
        format = "[:](dimmed)[$all_status$ahead_behind]($style)(white)";
        style = "blue dimmed";
        up_to_date = "";
      };
      kubernetes = {
        contexts = [
          {
            context_pattern = ".*prod.*";
            style = "red";
          }
        ];
        disabled = false;
        format = "\n k8s::[$context](yellow)[:](white dimmed)[$namespace](green dimmed)(white)";
      };
      nodejs = {
        disabled = false;
        format = "\n njs::[$version](purple)";
      };
      terraform = {
        disabled = false;
        format = "\n tfv::[$version](purple)";
      };
    };

  };
}
