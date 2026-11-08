use herdr.nu

export module mod {

    ### Completions

    def "nu-complete nix generations" [] {
        nixos-rebuild list-generations
        | from ssv -a
        | select Generation "Build-date" "NixOS version" Current
        | rename value description version current
        | update description { into datetime }
        | update current { into bool };
    };

    ### Alias

    export alias build = herdr record "nix build" 5sec { nh os test --dry --diff always --hostname $env.NH_HOST };
    export alias switch = herdr record "nix switch" 5sec { nh os switch --diff always --hostname $env.NH_HOST };
    export alias update = herdr record "nix update" 5sec { nh os test --update --diff always --hostname $env.NH_HOST };
    export alias gc = herdr record "nix gc" 5sec { nh clean all --keep 2 };

    ### Commands

    export def to-nix []: any -> any {
        $in
        | to json
        | with-env {data: $"($in)"} {
            nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; in pkgs.lib.generators.toPretty { } (builtins.fromJSON (builtins.getEnv "data"))'
        }
    }

    # List all available generations
    export def generations [] {
        nu-complete nix generations
        | rename ID DATE VERSION CURRENT;
    }

    # Rollback to a specific generation or the previous one
    export def rollback [
        generation?: int@"nu-complete nix generations"  # Optional: generation ID to rollback to
    ] {
        if ($generation == null) {
            nh os rollback --diff always;
        } else {
            # Switch to specific generation
            nh os rollback --to $generation --diff always;
        }
    }

    # Open Nix REPL with flake loaded
    export def flake-repl [] {
        nix repl --expr $"builtins.getFlake \"($env.NH_FLAKE)\"";
    }

    # Launch a nix shell with the specified packages installed
    export def shell [
        ...packages  # Packages to temporarily install
    ] {
        let prompt = $"(ansi cyan)nix(ansi reset):(ansi cyan_dimmed)($packages | str join $"(ansi reset):(ansi cyan_dimmed)")"
        nix-shell --command $"ESCAPE_MODE=\"($prompt)\" nu" -p ...$packages;
    }
}
