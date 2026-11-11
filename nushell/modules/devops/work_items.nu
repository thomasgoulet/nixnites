
export def format-work-items []: string -> any {

    # Mapping for WI fields
    const workitem_fields = {
        id: $.id
        title: $.fields."System.Title"
        created: $.fields."System.CreatedDate"
        createdby: $.fields."System.CreatedBy".uniqueName
        changed: $.fields."System.ChangedDate"
        changedby: $.fields."System.ChangedBy".uniqueName
        type: $.fields."System.WorkItemType"
        state: $.fields."System.State"
        description: $.fields."System.Description"
        acceptancecriteria: $.fields."Microsoft.VSTS.Common.AcceptanceCriteria"
        iteration: $.fields."System.IterationPath"
        parent: $.fields."System.Parent"
        relations: $.relations
    };

    $in
    | from json
    | select -o ...($workitem_fields | values)
    | rename ...($workitem_fields | columns)
    | upsert relations {|item|
        $item.relations
        | default []
        | where {|relation| $relation.attributes.name? in ["Child" "Parent" "Pull Request"]}
        | each {|relation|
            {
                type: $relation.attributes.name
                id: ($relation.url | split row "/" | split row "%2F" | last)
            }
        }
    }
}

export def work-item-list-recent [
    project: string  # DevOps project name
    date: datetime  # Will list work items created or closed after this date
] {
    let date_string = $date | format date "%Y-%m-%d";
    let query = $"SELECT * FROM WorkItems WHERE [System.TeamProject] = '($project)' AND \([System.CreatedDate] >= '($date_string)' OR [System.ChangedDate] >= '($date_string)'\)";

    az boards query --detect false --project $project --wiql $query -o json
    | format-work-items
    | reject relations
}

# Get work item details
export def work-item-details [
    id: string  # ID of the work item
    depth: int = 0  # Depth at which to resolve work item details of child or parent items
    direction: list<string> = [Child Parent]  # Direction in which related items are resolved (i.e. `[Child]` will only resolve child items and not parents)
] {
    az boards work-item show --detect false --id $id
    | format-work-items
    | resolve-work-item-relation $depth $direction
}

# Recursively obtain related work item details
export def resolve-work-item-relation [
    depth: int  # Depth at which to resolve work item details of child or parent items
    direction: list<string>  # Direction in which related items are resolved (i.e. `[Child]` will only resolve child items and not parents)
]: record -> record {

    if ($depth <= 0) {
        return $in;
    }

    $in
    | upsert relations {|item|
        $item.relations
        | each {|relation|
            if ($relation.type in $direction) {
                {
                    type: $relation.type
                    item: (work-item-details $relation.id ($depth - 1) [$relation.type])
                }
            } else {
                {
                    type: $relation.type
                    id: $relation.id
                }
            }
        }
    }
}
