$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand -n }
        to_string: { |v| $v | path expand -n | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand -n }
        to_string: { |v| $v | path expand -n | str join (char esep) }
    }
}

use std "path add"
path add '~/'
path add '~/bin'
path add 'cargo/bin'
path add '~/go/bin'
path add '~/.local/bin'
path add 'local/bin'
path add '~/.config/nushell/scripts'

$env.PATH = ($env.PATH | uniq)

# Use zoxide
let zoxide_init_path = '~/.cache/zoxide/init.nu' | path expand
if not ($zoxide_init_path | path exists) {
    mkdir ~/.cache/zoxide | ignore
    zoxide init nushell --cmd j | save -f $zoxide_init_path
}

# Use starship
let starship_init_path = '~/.cache/starship/init.nu' | path expand
if not ($starship_init_path | path exists) {
    mkdir ~/.cache/starship | ignore
    starship init nu | save -f $starship_init_path
}

$env.TRANSIENT_PROMPT_COMMAND = {"\n " + (starship module directory) + (starship module character)}
