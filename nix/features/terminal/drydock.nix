{
  config,
  lib,
  pkgs,
  ...
}:
let
  drydock = pkgs.rustPlatform.buildRustPackage rec {
    pname = "drydock";
    version = "1.3.1";

    src = pkgs.fetchFromGitHub {
      owner = "yetidevworks";
      repo = "drydock";
      tag = "v${version}";
      hash = "sha256-R3qCfp0pLQAWHgLgFi7tBhuPkS5acgrW9oc/Zw5Dr3I=";
    };
    nativeCheckInputs = [ pkgs.git ];

    cargoHash = "sha256-XvdUVnxkgbEI+ZnM2zsx1ighGTwN0uFhDZbtQewueuI=";

    meta = {
      description = "Live dashboard for a fleet of git repos: what's uncommitted, unpushed, and unreleased, at a glance";
      homepage = "https://github.com/yetidevworks/drydock";
      license = lib.licenses.mit;
      mainProgram = "drydock";
    };
  };
in
{
  home.packages = [ drydock ];

  xdg.configFile."drydock/config.toml" = {
    source = (pkgs.formats.toml { }).generate "drydock-settings.toml" {
      exclude = [ ];
      follow_nested_repos = false;
      follow_symlinks = false;
      max_depth = 2;
      prune = [ ];
      refresh = {
        debounce = "30s";
        interval = "5m";
        watch = true;
      };
      release = {
        changelog_files = [
          "CHANGELOG.md"
          "CHANGELOG"
          "changelog.md"
        ];
        max_subjects = 30;
        read_changelog = true;
        tag_pattern = "*[0-9]*";
      };
      remote = {
        concurrency = 2;
        fetch = true;
        interval = "30m";
        timeout = "20s";
      };
      roots = [
        "~/repos"
      ];
      status = {
        max_age = "1h";
        max_files = 200;
        untracked = "normal";
      };
      ui = {
        columns = [
          "group"
          "repo"
          "branch"
          "state"
          "fetched"
          "age"
          "changes"
          "ahead"
          "behind"
          "tag"
          "release"
        ];
        default_filters = [ ];
        default_since = "";
        default_sort = "activity";
        editor_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
        file_manager_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
        git_client_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
        terminal_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
      };
      visibility = {
        concurrency = 4;
        enabled = false;
        interval = "24h";
        timeout = "10s";
      };
    };
  };
}
