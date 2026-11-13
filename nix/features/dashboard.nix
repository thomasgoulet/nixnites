{ den, ... }:
{
  den.aspects.dashboard = {
    nixos =
      { lib, pkgs, ... }:
      let
        runtimeFile = "/run/glance/glance.yaml";
        overrideFile = "/var/lib/glance/glance.override.yaml";
        mergeScript =
          pkgs.writers.writePython3 "glance-merge-override"
            {
              libraries = [ pkgs.python3Packages.pyyaml ];
            }
            ''
              import os
              import tempfile

              import yaml

              RUNTIME = "${runtimeFile}"
              OVERRIDE = "${overrideFile}"
              # Maps a list path (field names only; list items add no segment)
              # to the key that matches items. Lists without a rule are appended.
              MERGE_KEYS = {
                  "pages": "name",
                  "pages.columns": "size",
                  "pages.columns.widgets": "type",
                  "pages.columns.widgets.groups": "title",
                  "pages.columns.widgets.groups.links": "title",
              }


              def merge(base, override, path):

                  # merge dicts
                  if isinstance(base, dict) or isinstance(override, dict):
                      base = base if isinstance(base, dict) else {}
                      override = override if isinstance(override, dict) else {}

                      return {
                          k: merge(base.get(k), override.get(k),
                                   f"{path}.{k}" if path else k)
                          for k in {**base, **override}
                      }

                  # merge lists
                  if isinstance(base, list) or isinstance(override, list):

                      base = base if isinstance(base, list) else []
                      override = override if isinstance(override, list) else []

                      merge_key = MERGE_KEYS.get(path)
                      output, index = [], {}

                      # walk base then override, folding items with the same key together
                      for item in base + override:

                          # merge it if it's already been seen
                          if merge_key and isinstance(item, dict) and merge_key in item:
                              position = index.get(item[merge_key])
                              if position is not None:
                                  output[position] = merge(output[position], item, path)
                                  continue
                              index[item[merge_key]] = len(output)

                          output.append(merge(item, None, path))

                      return output

                  # prioritize override
                  return base if override is None else override


              def main():
                  if not os.path.exists(OVERRIDE):
                      return
                  with open(RUNTIME) as f:
                      base = yaml.safe_load(f) or {}
                  with open(OVERRIDE) as f:
                      over = yaml.safe_load(f) or {}
                  merged = merge(base, over, "")

                  st = os.stat(RUNTIME)
                  fd, tmp = tempfile.mkstemp(dir=os.path.dirname(RUNTIME))
                  try:
                      with os.fdopen(fd, "w") as f:
                          yaml.safe_dump(merged, f, sort_keys=False, allow_unicode=True)
                      os.chown(tmp, st.st_uid, st.st_gid)
                      os.chmod(tmp, st.st_mode & 0o7777)
                      os.replace(tmp, RUNTIME)
                  except BaseException:
                      os.unlink(tmp)
                      raise


              main()
            '';
      in
      {
        # merge the values at service start
        systemd.tmpfiles.rules = [ "d /var/lib/glance 0755 root root -" ];
        systemd.services.glance.serviceConfig.ExecStartPre = lib.mkAfter [ "+${mergeScript}" ];

        services.glance = {
          enable = true;
          settings = {
            server = {
              port = 8887;
              bind_address = "127.0.0.1";
            };
            pages = [
              {
                name = "Search";
                width = "slim";
                head-widgets = [
                  {
                    type = "search";
                    search-engine = "http://127.0.0.1:8888/search?q={QUERY}";
                  }
                ];
                columns = [
                  {
                    size = "full";
                    widgets = [
                      {
                        type = "bookmarks";
                        groups = [
                          {
                            title = "Search";
                            links = [
                              {
                                title = "SearXNG";
                                url = "http://localhost:8888";
                              }
                              {
                                title = "NixOS Packages";
                                url = "https://search.nixos.org/packages";
                              }
                              {
                                title = "Home Manager Options";
                                url = "https://home-manager-options.extranix.com/";
                              }
                            ];
                          }
                        ];
                      }
                      {
                        type = "split-column";
                        widgets = [
                          {
                            type = "releases";
                            cache = "1h";
                            repositories = [
                              "nushell/nushell"
                              "helix-editor/helix"
                              "herdrdev/herdr"
                              "anomalyco/opencode"
                              "jesseduffield/lazygit"
                              "Canop/broot"
                              "kubernetes/kubernetes"
                              "hashicorp/terraform"
                            ];
                          }
                          {
                            type = "rss";
                            title = "Security";
                            feeds = [
                              {
                                url = "https://www.cyber.gc.ca/api/cccs/atom/v1/get?feed=alerts_advisories&lang=en";
                                title = "cyber.gc.ca";
                              }
                              {
                                url = "https://krebsonsecurity.com/feed/";
                                title = "krebsecurity";
                              }
                            ];
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          };
        };
      };
  };
}
