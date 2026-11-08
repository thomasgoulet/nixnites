---
name: to-spec
description: "Turn the current conversation into a spec file for a subsequent agent. It is a synthesis of what has already been discussed."
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec.
Do NOT interview the user; just synthesize what you already know.
Refuse to produce the spec if you lack information and clarify why.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already.

2. Create the spec using the template below.

3. Save the spec to a `PLAN-<FEATURE NAME>.md` file in the current directory for a separate agent to be able to implement it.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## Acceptance Criteria

A LONG, numbered list of acceptance criteria. Each acceptance criteria should be in the format of:

1. <feature> must <behavior> so that <benefit>.

<user-story-example>
1. The `GET /rest/users` endpoint must return the username so that it can be displayed on the website.
</user-story-example>

This list of acceptance criteria should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets.
They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype.
Trim to the decision-rich parts, not a working demo, just the important bits.

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
