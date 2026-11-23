---
name: tidy-skill
description: "Tidy a skill or agent doc after you edit it, cutting what doesn't change the agent's behaviour. Use once you have saved an edit to a skill, an AGENTS.md or a CLAUDE.md, or when asked to tidy one."
disable-model-invocation: false
---

# Tidy skill

Tidy a skill or an agent doc (`AGENTS.md`, `CLAUDE.md`, a file one of them points at) and apply the result in place.

**Done when** every sentence in scope has a verdict (keep, cut or rewrite) and you have delivered the report.

## 1. Scope

The scope is the change the invoker names. Without one: all of a new document; in a tracked file, the lines `git diff` shows for that document, or the last commit's when there are none; otherwise, what changed since the version you hold from earlier in this session. The whole document is in scope only when the invoker asks for it.

Copy each document in scope as it stands now to a temporary directory. The report diffs against that copy.

## 2. Prune

Read the `writing-for-agents` skill's `SKILL.md` and apply it to every sentence in scope. Then apply these rules:

- **Modular.** In a skill, detail that serves one flow, one repo or one case is cut and listed in the report, for the caller to pass as an argument. The skill keeps the general rule.
- **Harness-agnostic.** Name the action, not the tool: "use the browser", "poll until it prints `ready`". Every step works in any agent runtime.
- **Human steps.** A step that needs the human goes where the flow needs it, as an offer the agent makes at that point.

## 3. Unslop

Read the `unslop` skill's `SKILL.md` and apply it to every sentence in scope.

## 4. Independent review

When you can't start a subagent, leave steps 4 to 6 to the invoker and say so in the report.

Give a reviewer with no context the paths of the document, of `writing-for-agents` and of this file, plus the scope but not your verdicts, and ask for every sentence in scope that fails them. Apply each candidate you agree with. A candidate you can't judge becomes a doubt for step 5.

## 5. Test the doubts

For each doubt, give two subagents with no context of this session a task the sentence bears on: one with the document, one with the document minus the sentence. Cut the sentence when both runs do the same thing.

## 6. Description

When the description changed, its first sentence says what the skill does, naming the result, not the steps. In a model-invoked skill, a second sentence says when to use it: "Use when…", or "Use before…" for reference that has to load before the work, in the words a request would use.

When the trigger wording changed, test it. Write about fifteen requests: some that should fire the skill, near misses that belong to a neighbouring skill, and some that need no skill. One subagent with no context per description and model gets the list of skills the agent sees, with that description in place, and all the requests, and answers each with one skill or none. Run the old and the new description on your own model and, where you can choose, on a smaller one. Keep the new one only if it fires on at least as many of the requests that should fire it, and on no more of the others. A new skill has to fire on the requests that should fire it and on none of the others.

## 7. Report

Report to whoever invoked you:

- The diff against the copy from step 1, with the reason for each change beside it. For a human, render it as a page.
- What each doubt test and trigger test showed.
- Listed separately for the human: the cuts that change what the agent does, the contradictions you found and how you resolved them, and the reviewer candidates you rejected. An agent invoker passes this list up.
