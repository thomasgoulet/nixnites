#!/usr/bin/env nu

use std/help

module bar {

    export def "foo" [] {
        print aksjdkasjd
    }

}; use bar;

export-env {
    $env.config.table.mode = "single"
}

# Developer tooling to work with the ninites flake (https://github.com/thomasgoulet/nixnites)
def "main" [] {
    print (ls)
}

# Apply your changes to the current system
#
# Use after modifying your flake to apply pending changes to your system. Run `nites plan` to preview the changes.
#
# This command wraps `nh os switch`. You can pass extra flags to `nh` as arguments to this command. 
#
def "main apply" [] {
    nh os switch --diff always --hostname $env.NH_HOST
}

def "main test" [] {
    print $env
}

def "main look" [
    useless_arg : string@["does" "it" "work"]
] {
    tack -V
}

