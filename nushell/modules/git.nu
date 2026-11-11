export module mod {

    def "nu-complete git tags" [] {
        git tag -l | lines | reverse 
    }

    # List all commits since a specific tag or commit
    export def changelog [
        tag_or_commit: string@"nu-complete git tags"  # Tag from which to start listing commits
    ] {
        git log --oneline $"($tag_or_commit)..HEAD";
    }

}
