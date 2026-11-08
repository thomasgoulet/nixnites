def assert [
    condition: bool
    message: string
] {
    if not $condition {
        error make {msg: $message}
    }
}

def invoke-tool [
    home: string
    module: string
    name: string
    args: record
] {
    let encoded_args = $args | to json --raw
    let script = $"source '($module)'; main call-tool $env.HANDOFF_TOOL $env.HANDOFF_ARGS"
    with-env {
        HOME: $home
        HANDOFF_SCRIPT: $script
        HANDOFF_TOOL: $name
        HANDOFF_ARGS: $encoded_args
    } {
        ^nu --no-config-file -c $env.HANDOFF_SCRIPT
        | complete
    }
}

let module = $env.PWD | path join "nushell/tools/handoffs/mod.nu"
let test_home = $nu.temp-dir | path join $"handoff-tests-($nu.pid)-(random int 0..999999)"
mkdir $test_home

let discovery_script = $"source '($module)'; main list-tools"
let discovery = with-env {HOME: $test_home} {
    ^nu --no-config-file -c $discovery_script | complete
}
assert ($discovery.exit_code == 0) $"Tool discovery failed: ($discovery.stderr)"
let tools = $discovery.stdout | from json
let discovered_names = $tools | get name
assert (($discovered_names | sort) == ["handoff_complete", "handoff_create", "handoff_get", "handoff_list"]) "Handoff tools were not all discovered"
assert (($tools | where name == "handoff_create" | first | get description) | str contains "context, decisions, completed work, blockers, and next steps") "Create guidance is missing required authoring instructions"
assert (($tools | where name == "handoff_complete" | first | get description) | str contains "explicitly confirms deletion of this specific handoff ID") "Completion confirmation warning is missing"

let initially_empty = invoke-tool $test_home $module "handoff_list" {}
assert ($initially_empty.exit_code == 0) "Listing an empty store failed"
assert (($initially_empty.stdout | from json) == []) "An empty store did not return an empty collection"

let first_create = invoke-tool $test_home $module "handoff_create" {
    title: "Don't lose this handoff"
    focus: "test persistence"
    content: "# Next steps\n\nKeep this content; it contains 'quotes' and SQL-looking text: DROP TABLE handoffs;"
}
assert ($first_create.exit_code == 0) $first_create.stderr
let first = $first_create.stdout | from json
assert (($first | get id | str length) == 6) "Created ID was not six digits"
assert (($first | get id | str replace -a -r "\\d" "") == "") "Created ID was not numeric"
assert (($first | get title) == "Don't lose this handoff") "Parameterized title was not preserved"
assert (($first | get focus) == "test persistence") "Focus was not preserved"
assert (($first | get created_at | str ends-with "Z")) "Creation timestamp was not UTC"

let database = $test_home | path join ".local/share/handoffs/handoffs.sqlite3"
let collision_script = $"source '($module)'; unique-handoff-id '($database)' '($first.id)'"
let collision_retry = with-env {HOME: $test_home} {
    ^nu --no-config-file -c $collision_script | complete
}
assert ($collision_retry.exit_code == 0) $"ID collision retry failed: ($collision_retry.stderr)"
let retried_id = $collision_retry.stdout | str trim
assert ($retried_id != ($first | get id)) "An existing ID was not retried"
assert (($retried_id | str length) == 6) "Retry did not return a six-digit ID"

# A separate Nushell process must see the same SQLite-backed entry.
let second_create = invoke-tool $test_home $module "handoff_create" {
    title: "A second handoff"
    content: "Second body"
}
assert ($second_create.exit_code == 0) $second_create.stderr
let second = $second_create.stdout | from json
assert (($second | get id) != ($first | get id)) "Created IDs were not unique"
assert (($second | get focus) == null) "An omitted focus was not stored as null"

let listed = invoke-tool $test_home $module "handoff_list" {}
assert ($listed.exit_code == 0) $listed.stderr
let entries = $listed.stdout | from json
assert (($entries | length) == 2) "List did not return both active handoffs"
assert (($entries | first | get id) == ($second | get id)) "List was not newest first"
assert ("content" not-in ($entries | first | columns)) "List unexpectedly returned handoff content"

let retrieved = invoke-tool $test_home $module "handoff_get" {id: ($first | get id)}
assert ($retrieved.exit_code == 0) $retrieved.stderr
let full_entry = $retrieved.stdout | from json
assert (($full_entry | get content) == "# Next steps\n\nKeep this content; it contains 'quotes' and SQL-looking text: DROP TABLE handoffs;") "Get did not return the original Markdown content"

let blank_title = invoke-tool $test_home $module "handoff_create" {title: "  ", content: "Body"}
assert ($blank_title.exit_code != 0) "A blank title was accepted"
assert ($blank_title.stderr | str contains "title must not be blank") "Blank-title error was unclear"
let blank_content = invoke-tool $test_home $module "handoff_create" {title: "Title", content: "  "}
assert ($blank_content.exit_code != 0) "Blank Markdown content was accepted"
assert ($blank_content.stderr | str contains "content must not be blank") "Blank-content error was unclear"

let missing_get = invoke-tool $test_home $module "handoff_get" {id: "000000"}
assert ($missing_get.exit_code != 0) "An unknown handoff ID was accepted by get"
assert ($missing_get.stderr | str contains "No active handoff found with ID 000000") "Unknown-ID get error was unclear"
let missing_complete = invoke-tool $test_home $module "handoff_complete" {id: "000000"}
assert ($missing_complete.exit_code != 0) "An unknown handoff ID was accepted by complete"
assert ($missing_complete.stderr | str contains "No active handoff found with ID 000000") "Unknown-ID complete error was unclear"

let completed = invoke-tool $test_home $module "handoff_complete" {id: ($first | get id)}
assert ($completed.exit_code == 0) $completed.stderr
let remaining = (invoke-tool $test_home $module "handoff_list" {}).stdout | from json
assert (($remaining | length) == 1) "Completed handoff remained in list"
assert (($remaining | first | get id) == ($second | get id)) "Completing a handoff removed the wrong entry"
let completed_get = invoke-tool $test_home $module "handoff_get" {id: ($first | get id)}
assert ($completed_get.exit_code != 0) "Completed handoff remained retrievable"

rm -r $test_home
print "Handoff tool tests passed"
