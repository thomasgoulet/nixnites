def main [] {
    help main
}

def "main list-tools" [] {
    [
        {
            name: "handoff_create"
            description: "Create a persistent handoff for the next session. Write a concise Markdown summary of relevant context, decisions, completed work, blockers, and next steps. Incorporate the supplied focus when present. Avoid duplicating information already captured in other artifacts, and redact sensitive information."
            input_schema: {
                type: "object"
                properties: {
                    title: {
                        type: "string"
                        description: "A concise, nonblank title for the handoff"
                    }
                    content: {
                        type: "string"
                        description: "Markdown handoff content"
                    }
                    focus: {
                        type: "string"
                        description: "Optional focus for the next session"
                    }
                }
                required: ["title", "content"]
                additionalProperties: false
            }
        }
        {
            name: "handoff_list"
            description: "List active handoffs, newest first. Returns metadata only: id, title, focus, and created_at. Returns an empty list when there are no active handoffs. Use this to discover handoff IDs before retrieving one."
            input_schema: {
                type: "object"
                properties: {}
                additionalProperties: false
            }
        }
        {
            name: "handoff_get"
            description: "Retrieve a handoff, including its full Markdown content, by its six-digit ID."
            input_schema: {
                type: "object"
                properties: {
                    id: {
                        type: "string"
                        description: "Six-digit handoff ID"
                        pattern: "^\\d{6}$"
                    }
                }
                required: ["id"]
                additionalProperties: false
            }
        }
        {
            name: "handoff_complete"
            description: "Permanently deletes the handoff with the specified ID; it cannot be recovered or archived. Call this tool only after the user explicitly confirms deletion of this specific handoff ID. Do not treat a request to list, review, or retrieve a handoff as consent to delete it."
            input_schema: {
                type: "object"
                properties: {
                    id: {
                        type: "string"
                        description: "Six-digit ID of the handoff to permanently delete"
                        pattern: "^\\d{6}$"
                    }
                }
                required: ["id"]
                additionalProperties: false
            }
        }
    ] | to json
}

def "main call-tool" [
    tool_name: string  # Name of the tool to call
    args: string = "{}"  # Arguments for the tool in JSON format
] {
    let parsed_args = $args | from json

    match $tool_name {
        "handoff_create" => {
            create-handoff ($parsed_args | get title) ($parsed_args | get -o focus | default null) ($parsed_args | get content) | to json
        }
        "handoff_list" => {
            list-handoffs | to json
        }
        "handoff_get" => {
            get-handoff ($parsed_args | get id) | to json
        }
        "handoff_complete" => {
            complete-handoff ($parsed_args | get id) | to json
        }
        _ => {
            error make {msg: $"Unknown tool: ($tool_name)"}
        }
    }
}

def ensure-handoff-database [] {
    let database = $nu.home-dir | path join ".local/share/handoffs/handoffs.sqlite3";
    let directory = $database | path dirname;
    mkdir $directory

    if not ($database | path exists) {
        {placeholder: "initialized"} | into sqlite $database -t handoff_bootstrap
        open $database | query db "CREATE TABLE IF NOT EXISTS handoffs (id TEXT PRIMARY KEY, title TEXT NOT NULL, focus TEXT, content TEXT NOT NULL, created_at TEXT NOT NULL)" | ignore
        open $database | query db "DROP TABLE IF EXISTS handoff_bootstrap" | ignore
    }

    $database
}

def handoff-id-exists [
    database: string
    id: string
] {
    open $database
    | query db "SELECT id FROM handoffs WHERE id = :id" -p {id: $id}
    | is-not-empty
}

def unique-handoff-id [
    database: string
    candidate?: string
] {
    let candidate = $candidate | default (random int 100000..999999 | into string)
    if (handoff-id-exists $database $candidate) {
        unique-handoff-id $database
    } else {
        $candidate
    }
}

def create-handoff [
    title: string
    focus: any
    content: string
] {
    if ($title | str trim | is-empty) {
        error make {msg: "Handoff title must not be blank"}
    }
    if ($content | str trim | is-empty) {
        error make {msg: "Handoff Markdown content must not be blank"}
    }

    let database = ensure-handoff-database
    let id = unique-handoff-id $database
    let created_at = date now | date to-timezone UTC | format date "%Y-%m-%dT%H:%M:%S%.fZ"

    open $database
    | query db "INSERT INTO handoffs (id, title, focus, content, created_at) VALUES (:id, :title, :focus, :content, :created_at)" -p {
        id: $id
        title: $title
        focus: $focus
        content: $content
        created_at: $created_at
    }
    | ignore

    {
        id: $id
        title: $title
        focus: $focus
        created_at: $created_at
    }
}

def list-handoffs [] {
    open (ensure-handoff-database)
    | query db "SELECT id, title, focus, created_at FROM handoffs ORDER BY created_at DESC, id DESC"
}

def get-handoff [id: string] {
    let result = (
        open (ensure-handoff-database)
        | query db "SELECT id, title, focus, content, created_at FROM handoffs WHERE id = :id" -p {id: $id}
    );
    if ($result | is-empty) {
        error make {msg: $"No active handoff found with ID ($id)"}
    }
    $result | first
}

def complete-handoff [id: string] {
    let result = (
        open (ensure-handoff-database)
        | query db "DELETE FROM handoffs WHERE id = :id RETURNING id" -p {id: $id}
    );
    if ($result | is-empty) {
        error make {msg: $"No active handoff found with ID ($id)"}
    }
    {id: $id, deleted: true}
}
