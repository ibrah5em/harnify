# Interview: 5-8 questions

If the idea is empty, ask for it in one plain line and wait. That counts as question 1.

Then two rounds, at most 4 questions each, through `AskUserQuestion`. Derive every option
from the idea, never from a generic menu. Put your pick first, labelled "(Recommended)", with
the reason in its description. Use multi-select where choices stack. Skip anything the idea,
the code or the global instructions already answer. Don't pad to reach 8.

**Round 1, the shape:**
- The stack: language, framework, package manager. It picks skills and rules; harnify doesn't
  install it.
- Where it runs or ships.
- The agent's main job: greenfield build, maintenance, content, data, research.
- The one idea-specific factor that changes the most: UI language and RTL, database, auth,
  test strategy.

**Round 2, the work** (built on round 1):
- What v1 must include. Each outcome becomes an item in `plan.md` with a *Done when*, so push
  for concrete, checkable ones. "Good error handling" can't be checked; "an unknown code
  returns 404 with a JSON `detail`" can.
- Specialist agents, as a multi-select of 2-4 proposals that fit this project. A reviewer or
  checker that the work actually needs beats a generic role.
- Which rules would cost the most if broken, as a multi-select. Derive them from the stack and
  the global instructions: "a push to `main` deploys", "never read `.env`", "`dist/` is
  generated". Each pick becomes a `permissions.deny` rule where one can express it
  (`toolbox.md`), and a line in Conventions where it can't.

Plugins and MCP servers are not asked here. They're one separate question in `toolbox.md`,
after discovery, so the options are real candidates.

**Existing mode:** the code and docs answer most of this. Ask only what they leave open,
even if that's nothing, and never re-ask something they record as decided. One round is
usually enough.

Every settled answer that someone might later want to reopen becomes a file in
`docs/agent/decisions/`, with the reason and what was rejected.
