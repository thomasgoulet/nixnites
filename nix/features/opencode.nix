# opencode (https://opencode.ai), the AI coding agent, with its MCP servers and per-agent prompts.
{
  den,
  lib,
  ...
}:
let
  prompts = {
    docs = "You research documentation. Use the Context7 MCP to search official documentation, then answer the user's prompt based on what you find. Never guess — always search. Do not edit any file.";
    review = "You review the current branch against master (or main) branch. Structure your feedback in three sections: High-Level Architecture Decisions, Good Practices, Code Smells (nit & bugs). Indicate if the feedback is positive (+) or negative (-). Use the Context7 MCP to look up library documentation when required to clarify library usage. Do not edit any file.";
  };

  skills =
    ./opencode/skills
    |> lib.filesystem.listFilesRecursive
    |> map (file: {
      "${(lib.removeSuffix ".md" (baseNameOf file))}" = file;
    })
    |> lib.attrsets.mergeAttrsList;
in
{
  den.aspects.opencode = {

    homeManager =
      {
        config,
        inputs',
        pkgs,
        ...
      }:
      let
        pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
        colors = config.lib.stylix.colors.withHashtag;
      in
      {
        home.packages = [
          pkgs.context7-mcp
          pkgs-stable.pdf-oxide
          inputs'.nu-mcp.packages.default
        ];

        home.sessionVariables = {
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        };

        programs.opencode = {
          enable = true;
          enableMcpIntegration = false;
          skills = skills;
          settings = {

            mcp.servers = {
              context7 = {
                type = "local";
                command = [ "context7-mcp" ];
              };
              nu-mcp = {
                type = "local";
                command = [
                  "nu-mcp"
                  "--add-read-path"
                  "/nix/store"
                  "--tools-dir"
                  "${config.xdg.configHome}/nushell/tools"
                  "--enable-nu"
                  "--add-path"
                  "${config.home.homeDirectory}/.local/share/handoffs"
                ];
              };
            };

            default_agent = "build";
            update = "disable";
            experimental = {
              todo = true;
              background_compaction = true;
            };
            permissions = [
              {
                action = "context7*";
                resource = "*";
                effect = "deny";
              }
              {
                action = "external_directory";
                resource = "*";
                effect = "ask";
              }
            ];
            agents = {
              review = {
                mode = "subagent";
                color = colors.base0E;
                system = prompts.review;
                permissions = [
                  {
                    action = "edit";
                    resource = "*";
                    effect = "deny";
                  }
                  {
                    action = "context7*";
                    resource = "*";
                    effect = "allow";
                  }
                ];
              };
              explore.permissions = [
                {
                  action = "external_directory";
                  resource = "*";
                  effect = "ask";
                }
              ];
              docs = {
                mode = "all";
                color = colors.base0D;
                system = prompts.docs;
                permissions = [
                  {
                    action = "*";
                    resource = "*";
                    effect = "deny";
                  }
                  {
                    action = "context7*";
                    resource = "*";
                    effect = "allow";
                  }
                  {
                    action = "read";
                    resource = "*";
                    effect = "allow";
                  }
                  {
                    action = "webfetch";
                    resource = "*";
                    effect = "allow";
                  }
                  {
                    action = "websearch";
                    resource = "*";
                    effect = "allow";
                  }
                  {
                    action = "external_directory";
                    resource = "*";
                    effect = "ask";
                  }
                ];
              };
              build.color = colors.base0E;
              plan.color = colors.base0B;
            };
          };
        };

        xdg.configFile."opencode/cli.json" = {
          force = true;
          text = builtins.toJSON {
            "$schema" = "https://opencode.ai/v2/cli.json";
            theme = {
              name = config.stylix.opencode;
              mode = "dark";
            };
            scroll.acceleration = true;
            diffs.wrap = "none";
            session = {
              sidebar = "hide";
              scrollbar = false;
              thinking = "show";
            };
            animations = true;
            tabs.mode = "off";
          };
        };
      };
  };
}
