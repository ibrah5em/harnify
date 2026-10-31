# harnify

A Claude Code plugin, md only, that sets up a project's `.claude/` from an idea: AGENTS.md,
picked skills, agents and rules, and `docs/agent/` that later sessions keep current. In
Ibrahem's words: "all I wanted is to automate the idea of setting the .claude folder each time
I start a project."

Its own case is an idea in an empty folder, which Claude Code's `/init` declines. In an
existing repo, CLAUDE.md is left to `/init`; harnify adds only its layer.

## Layout

- `skills/init/SKILL.md`: the flow, run as `/harnify:init [idea]`
- `skills/init/interview.md`, `toolbox.md`, `templates.md`: the pieces it follows
- `library/`: Ibrahem's rules and skills, copied into projects (`working-style.md`,
  `rtl-arabic-web`, `web-a11y`)
- `.claude-plugin/plugin.json`

Load it for one session with `claude --plugin-dir ~/projects/harnify`. Check it with
`claude plugin validate .`.

## How we work here

- Claude drafts the md files, Ibrahem rewrites them.
- Markdown and JSON config only in what the tool installs or runs: no `.py`, `.sh`, hooks or
  installed code. A helper script, if one is ever needed, lives outside the skill and is never
  copied into a project.
- Budget: about 500 lines of harnify's own md (`wc -l skills/init/*.md library/rules/*.md`),
  library skills not counted. Anything past that needs a reason Ibrahem agrees to.
- Commit only when Ibrahem asks. No remote until he asks.

## Why it's small

vold (`~/projects/Archive/Claude-init`, public as `ibrah5em/vold`) grew to ~1,300 lines of md
plus ~1,400 lines of hooks and scripts installed into every project. Each piece of code forced
the next one: installed hooks needed hash-tracked upgrades, a generated `state.md` needed a
generator and a checker, outside skills needed a quarantine agent. None of it improved what the
setup picks for a project, which is the model's judgment and lives in the md. Once harnify
works, archive vold with a pointer here.

## Settled (2026-10-31)

- v1 is Claude only, flat layout. Other harnesses are v2; AGENTS.md as the source already
  covers Codex.
- Nothing global: every CLI call takes `--scope project` (plugins: `local` in a shared repo if
  the person picks it), nothing is written under `~/.claude/` or to `~/.claude.json`.
- `docs/agent/` is `plan.md` (open items only, each with a checkable *Done when*),
  `logs/YYYY-MM-DD-slug.md` (written once, ends with `Next:`), `decisions/` and `notes/`
  (frontmatter is `description:` only). A closed item moves with its Proof into the closing
  session's log. Dropped from vold because each needed `agentdocs.py`: `state.md`, `work/`,
  `memory/` and its index, `archive/`, numbered logs, `difficulty`/`after:`, wikilinks.
- The write policy lives in AGENTS.md's Docs section, always loaded. A path-scoped rule loads
  too late to prompt the session-end log.
- Guards are `permissions.deny` entries in `settings.json`. They stop the usual command form
  and aren't a security boundary. Verified 2026-10-31: a deny rule blocks in
  `bypassPermissions`, also inside `cd . && …`.
- Public skills are never fetched or read during init, only suggested. Plugins and MCP servers
  are one optional question after discovery.
- No upgrade mode: a project with `docs/agent/plan.md` is left alone.
- `working-style.md` goes into every project, since cloud sessions and other contributors never
  load the global CLAUDE.md.
- Name: harnify. Rejected: loom (Atlassian's product), agentify (two projects in this space),
  repoify (reads as "create a repo").
- Costs of md only, accepted: rules are advice except deny entries; `docs/agent/` can drift
  with nothing checking it; mechanical steps vary run to run; testing means trying it on a
  scratch folder.

## Findings

- arXiv:2602.11988 (ETH Zurich): LLM-generated context files lowered agent success in 5 of 8
  settings and raised cost by over 20%; they helped only in repos with no docs. Hence the
  ~60-line cap on a generated AGENTS.md + CLAUDE.md. From secondary coverage; the paper itself
  hasn't been read.
- Anthropic's long-running harness post: a feature list plus a progress log plus git, and JSON
  for the list because models overwrite md lists more. harnify's answer is the plan.md editing
  rules in the AGENTS.md template.
- Closest tools (super-bootstrap, agent-project-bootstrap) grew hooks the way vold did. vold's
  survey: `~/projects/Archive/Claude-init/docs/agent/notes/landscape.md`.

## Open

- Both modes trialled headless on 2026-10-31, global state unchanged both times. New mode
  (scratch recipe-site idea): 25 turns, $0.35, matched the templates; fixed the plugin check
  in step 4. Existing mode (clone of draw-to-web, 225-line gitignored CLAUDE.md): 15 turns,
  $0.87, kept the CLAUDE.md text and added `@AGENTS.md`. It ran `npx prettier`, changed an
  existing `autoMemoryEnabled` value and sorted the deny array; SKILL.md now forbids all
  three. Re-run on a fresh clone ($0.94): no npm/npx/node call in the tool log, the
  `autoMemoryEnabled: true` value was left and proposed in the report, and the settings diff
  only appends. New in the re-run: it put plugins at `--scope local` on its own, reasoning
  that project scope pushes your picks onto teammates. Now `toolbox.md`, Scope: solo repo →
  project, no question; others commit → ask, local recommended. Not re-run yet.
- README, LICENSE.
