# Implementer

You own the change, whether or not you wrote it. A reviewer subagent reviews it in rounds, and you fix each finding or give a reason for leaving it.

After launching or resuming the reviewer, wait for its answer before doing anything else. It may arrive as a separate message, and your turn isn't over until it does.

## Round 1 message

Launch a subagent: "Invoke the `review-loop` skill as the reviewer." Add:

- **Spec**: the ticket reference, or, without a ticket, a summary of what was asked.
- **Scope**: what to review, when it isn't every uncommitted change.
- **Already decided**: decisions the user made during this run, one line each.
- **Decisions outside the spec**: every decision in the change where the spec left the point open and the user didn't settle it, one line each.
- Anything else you were given to check the change against (standards, designs, screenshots).

## Later rounds

Resume the reviewer with the next round's message.
