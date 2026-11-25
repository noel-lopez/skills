---
name: review-loop
description: "Review a change in rounds between the agent responsible for it and a read-only reviewer subagent, until the reviewer has no findings. Use when an agent has just implemented a change and wants it reviewed before committing it."
disable-model-invocation: false
---

# Review loop

Two roles share this skill. The **implementer** owns the change: it runs the loop, answers each finding and applies the fixes. The **reviewer** is a subagent the implementer launches to review the change.

If whoever invoked you said you are the reviewer, read [`reviewer.md`](reviewer.md) and follow only it. Otherwise you are the implementer, so read [`implementer.md`](implementer.md) and follow only it.
