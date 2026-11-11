export module mod {

    ### Aliases

    export alias kube = kubectl;

    ### Utility

    def argparse [
        command: list<string>
    ] {
        mut args = []
        mut namespace = ""
        mut all = false
        mut expecting_namespace = false

        for word in ($command | where $it != "" | skip 1) {
            if $expecting_namespace {
                $namespace = $word
                $expecting_namespace = false
            } else if $word in ["-n" "--namespace"] {
                $expecting_namespace = true
            } else if $word in ["-A" "-a" "--all"] {
                $all = true
            } else {
                $args = ($args | append $word)
            }
        }

        let flags = if $all {
            ["-A"]
        } else if ($namespace | is-not-empty) {
            ["-n" $namespace]
        } else {
            []
        }

        {
            args: $args
            flags: $flags
            flag_id: ($flags | str join ".")
        }
    }

    def "watch" [
        closure: closure
        delay: int
    ] {
        mut lines_printed = 0
        mut iterations = 1;
        let start_time = (date now);
        loop {
            let output = (do $closure);

            if $lines_printed > 0 { print -n $"\e[($lines_printed + 1)A\e[J" }

            print $output
            print $"(ansi light_gray_italic)  ran ($iterations) time(if ($iterations > 1) {"s"} else {""}) since ($start_time | date humanize) - press q to quit"

            # block for up to 1 second waiting for a single keypress; empty output on timeout
            let key = (^bash -c $"read -t ($delay) -n 1 key; echo \"$key\"" | str trim)
            if ($key == "q") { break; }

            $lines_printed = ($output | table | lines | length)
            $iterations += 1;
        }
    }

    def "recursive-paths" [
        resource: any,
        prefix = ""
    ] {
        let prefix_with_dot = if ($prefix | is-empty) { $prefix } else { $prefix + "." }

        match ($resource | describe -d | get type) {
            "record" => {
                return (
                    $resource
                    | columns
                    | each { |inside| let i = $inside; recursive-paths ($resource | get $i) $"($prefix_with_dot)($i)" }
                    | flatten
                    | prepend { value: $prefix, description: ($resource | to json) }
                );
            },
            "table" | "list" => {
                return (
                    0..(($resource | length) - 1)
                    | each { |inside| let i = $inside; recursive-paths ($resource | get ($i | into cell-path)) $"($prefix_with_dot)($i)" }
                    | flatten
                    | prepend { value: $prefix, description: ($resource | to json) }
                );
            },
            _ => {
                return { value: $prefix, description: $resource }
            }
        }
    }

    ### Completions

    def "nu-complete kubectl contexts" [] {
        {
            completions: (
                with-env { KUBECONFIG: ($env.HOME | path join ".kube" "config") } {
                    kubectl config get-contexts
                }
                | from ssv -a
                | iter filter-map {|c|
                    {
                        value: ($c.NAME)
                        description: $"($c.CLUSTER | fill -w 15) namespace ($c.NAMESPACE | fill -w 15)"
                    }
                }
                | prepend { value: "-", description: "Reset to the main kubeconfig" }
            )
            options: {
                match_description: true
            }
        }
    }

    def "nu-complete kubectl namespaces" [] {
        cache hit kube.namespaces 120 {
            kubectl get namespaces
            | from ssv
            | where NAME != "default"
            | get NAME
            | prepend NONE
        };
    }

    def "nu-complete kubectl kinds" [] {
        cache hit kube.kinds 120 {
            kubectl api-resources
            | from ssv
            | select SHORTNAMES NAME
            | insert len { $in.NAME | str length }
            | sort-by len
            | get NAME SHORTNAMES
            | flatten
            | uniq
        };
    }

    # Completes instances for `k`
    @interactive # Interactives prevents nushell caching results by accident
    def "nu-complete kubectl kind instances" [
        place: record
    ] {
        let ctx = argparse $place.command

        cache hit $"kube.kind.($ctx.args.0).($ctx.flag_id)" 120 {
            kubecolor --force-colors get $ctx.args.0 ...$ctx.flags
            | from ssv
            | rename --block { ansi strip | str lowercase }
            | each { {value: $in.name, description: ($in | reject name | to nuon)} }
        };
    }

    # Completes the possible paths for `k`
    @interactive # Interactives prevents nushell caching results by accident
    def "nu-complete kubectl kind instance paths" [
        place: record
    ] {
        let ctx = argparse $place.command
        let kind = $ctx.args.0;
        let instance = $ctx.args.1;

        let resource = cache hit $"kube.($kind).($instance)" 120 {
            kubectl get $kind $instance ...$ctx.flags -o yaml | from yaml
        };

        {
            completions: (
                cache hit $"kube.($kind).($instance).paths" 120 {
                    recursive-paths $resource
                }
            )
            options: {
                match_description: true
            }
        }
    }


    def "nu-complete kubectl shell" [] {
        cache hit kube.restartable 120 {
            kubectl get pods -o wide
            | from ssv -a
            | select NAME NODE
            | rename value description
            | append (
                kubectl get nodes -o wide
                | from ssv -a
                | select NAME INTERNAL-IP
                | rename value description
            )
        };
    }

    # Powered-up kubectl
    export def k [
        kind: string@"nu-complete kubectl kinds"  # Kind
        instance?: string@"nu-complete kubectl kind instances"  # Name
        path?: string@"nu-complete kubectl kind instance paths"  # Path to filter
        --namespace (-n): string@"nu-complete kubectl namespaces"  # Namespace to list resources in
        --all (-a)  # Search in all namespaces
        --delete (-D)  # Delete a resource
        --decode  # Decodes secret values using `base64 --decode`
        --edit (-e)  # Edit a resource
        --get (-g)  # Get a resource's full definition
        --logs (-l)  # Get the logs of a resource
        --logs-previous (-L)  # Get the logs of the previous pod
        --follow (-f)  # Get the logs of a resource and follow them
        --port-forward (-p): int  # Port-forward the resource's port to localhost
        --restart (-r)  # Restart the resources's pods
        --watch (-w)  # Watch the output
    ] {

        let namespace_flags = (
            if $all { ["-A"] } else if ($namespace != null) { ["-n", $namespace] } else { [] }
        );

        # These can only execute if a name is specified
        if ($instance != null) {

            # Restart a resource
            if ($restart) {
                return (kubectl rollout restart $"($kind)/($instance)" ...$namespace_flags);
            }

            # Port-forward a resource
            if ($port_forward != null) {
                kubectl port-forward $"($kind)/($instance)" $"($port_forward):($port_forward)" ...$namespace_flags;
                return;
            }

            # Outputs the logs for a resource
            if ($logs or $logs_previous) {
                let log_flags = if $logs_previous { ['-p'] | append $namespace_flags } else { $namespace_flags }
                kubectl logs $"($kind)/($instance)" ...$log_flags | hl;
                return;
            }

            # Output all logs and follow them
            if ($follow) {
                kubectl logs $"($kind)/($instance)" ...$namespace_flags --follow | hl --follow;
                return;
            }

            # Deletes a resource
            if ($delete) {
                cache invalidate;
                return (kubectl delete $kind $instance ...$namespace_flags);
            }

        }

        # Edit a resource or a list of resource
        if ($edit) {
            if ($instance == null) {
                kubectl edit $kind ...$namespace_flags;
            } else {
                kubectl edit $kind $instance ...$namespace_flags;
            }
            return;
        }

        # Get the full definition
        if ($get) {
            return (
                if ($instance != null) {
                    cache hit $"kube.($kind).($instance)" 120 {
                        kubectl get $kind $instance ...$namespace_flags -o yaml
                        | from yaml
                    };
                } else {
                    cache hit $"kube.items.($kind)" 120 {
                        kubectl get $kind ...$namespace_flags -o yaml
                        | from yaml
                        | get items
                    };
                }
            );
        }

        if ($decode) {
            if ($kind not-in ["secret" "secrets"] or $instance == null) {
                error make -u {msg: "`--decode` cannot be used for non-secret kinds or without specifying an instance"};
            }
            return (
                cache hit $"kube.($kind).($instance)" 120 {
                    kubectl get $kind $instance ...$namespace_flags -o yaml
                    | from yaml
                } | get data
                | items {|key, value| {$key: ($value | base64 --decode)}}
                | reduce { |row, acc| $acc | merge $row }
            );

        }

        if ($path | is-not-empty) {
            return (
                cache hit $"kube.($kind).($instance)" 120 {
                    kubectl get $kind $instance ...$namespace_flags -o yaml
                    | from yaml
                }
                | get (
                    $path
                    | split row '.'
                    | each { let i = $in; try {$i | into int} catch {$i} }
                    | into cell-path
                )
            );
        }

        # List the resources
        let output = {
            kubecolor --force-colors get $kind ...$namespace_flags
            | from ssv
            | rename --block { ansi strip | str lowercase }
            | if ($instance | is-not-empty) { find $instance } else { $in }
            | if ($in | is-not-empty) { $in } else { null }
        };

        if ($watch) {
            return (watch $output 3);
        }

        return ( do $output );

    }

    # List and change context
    export def --env "k ctx" [
        context: string@"nu-complete kubectl contexts"  # Context (fuzzy)
        namespace?: string@"nu-complete kubectl namespaces"  # Namespace
        --default (-d)  # Change the context in the main kubeconfig instead of a temporary one
    ] {
        cache invalidate
        hide-env --ignore-errors KUBECONFIG

        if ($context == "-") {
            return;
        }

        if ($default) {
            if ($namespace != null) {
                kubectl config set-context $context --namespace $namespace o+e> (null-device);
            }
            kubectl config use-context $context o+e> (null-device);
            return;
        }

        let kube_dir = ($env.HOME | path join ".kube");
        let main_config = ($kube_dir | path join "config");

        ls $kube_dir
        | where modified < ((date now) - 2day) and name =~ ".*\\..*\\.config"
        | each { rm $in.name }

        let ctx = (
            with-env { KUBECONFIG: $main_config } {
                kubectl config view --minify --context $context -o json
            }
            | from json
            | get contexts.0.context
        );

        let namespace = (
            if ($namespace != null) { $namespace } else { $ctx | get -o namespace | default "default" }
        );

        let path = (
            $kube_dir
            | path join $"($namespace).($ctx.cluster).config"
        );

        {
            kind: Config
            apiVersion: v1
            contexts: [{
                name: $context
                context: {cluster: $ctx.cluster, user: $ctx.user, namespace: $namespace}
            }]
            current-context: $context
        }
        | to yaml
        | save -f $path

        $env.KUBECONFIG = ([$path $main_config] | str join (char esep));
    }

    # Exec into a pod or a node
    export def "k shell" [
        name: string@"nu-complete kubectl shell"  # Name of node or pod to exec into
        shell = "/bin/bash"  # Process to launch (when specifying a pod)
        --new (-n)  # Start a new pod with the specified name using an alpine image
    ] {
        if ($new) {
            kubectl run $name --rm -it --image=alpine -- sh;
            return;
        }

        let pods = (
            kubectl get pods
            | from ssv -a
            | get NAME
        );
        if ($name in $pods) {
            kubectl exec --stdin --tty $name -- $shell;
            return;
        }

        try {
            let nodes = (
                kubectl get nodes
                | from ssv -a
                | get NAME
            );
            if ($name in $nodes) {
                kubectl node_shell $name;
                return;
            }
        }
        error make -u { msg: $"No resource called ($name). Specify '-n' to launch a new pod with that name." }
    }
}
