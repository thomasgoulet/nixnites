export module mod {

    export alias h = herdr;

    # Opens $EDITOR and registers with herdr
    export def edit [
        ...args: string  # Arguments to pass to $EDITOR
    ] {
        report $"($env.EDITOR) ($args | str join ' ')" 0sec { run-external $env.EDITOR }
    }

    # Report a closure's execution in herdr
    export def report [
        id: string  # Id for the process
        remove_timeout: duration  # Time to wait before clearing the agent
        closure: closure  # Closure to execute
    ] {
        if ("HERDR_PANE_ID" not-in $env) {
            do $closure;
            return;
        }
        herdr pane report-agent $env.HERDR_PANE_ID --source $id --agent $id --state working;

        try {do $closure};

        herdr pane report-agent $env.HERDR_PANE_ID --source $id --agent $id --state idle;
        job spawn {
            sleep $remove_timeout;
            herdr pane release-agent $env.HERDR_PANE_ID --source $id --agent $id;
        } o> (null-device);
    }
}
