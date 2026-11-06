# Launch

Drafts for Ibrahem to rewrite. awesome-claude-code requires a human-written recommendation, so
each draft gets rewritten before it goes out.

## Plugin directory

claude.ai/directory/manage → Submit new → Plugin bundle.

- Repository `ibrah5em/harnify`, path empty (plugin.json is at the root), branch `main`
- Listing details are read from `plugin.json` and the README, nothing to type
- Data handling: no personal data read or stored, nothing sent to other services, no
  retention, not aimed at under-18s. harnify only writes files in the open project
- Updates: GitHub push webhook, auto-publish off, so a pushed commit waits for Publish

## claudepluginhub

claudepluginhub.com/tools/submit-plugin, URL `https://github.com/ibrah5em/harnify`.

## awesome-claude-code

Web issue form only, no PR, no `gh`. Eligible from 2026-11-14 (14 days after the first
commit). One line, no pitch:

> harnify: sets up a project's `.claude/`, AGENTS.md and a `docs/agent/` plan from an idea in
> an empty folder, in markdown only with no hooks or scripts.

## Show HN

Title: `Show HN: Harnify – a Claude Code plugin that sets up .claude/ from an idea`

Text:

I kept setting up the same `.claude/` folder by hand at the start of every project: my
rules, a few agents, the skills that fit the stack, a place for sessions to write down what
they did. Claude Code's `/init` needs existing code to read, so in an empty folder it has
nothing to go on.

harnify asks 5–8 questions about what you're building and writes AGENTS.md, `.claude/`
(rules, agents, skills, `permissions.deny` entries) and a `docs/agent/` plan with a checkable
"done when" per item. It's markdown only. The previous version of this idea grew to 1,400
lines of hooks and scripts installed into every project, and none of it improved what got
picked.

I measured it on tinydb, 3 headless runs per cell, global CLAUDE.md kept out:

- Coding task: 18/18 with `/init` alone, 18/18 with harnify added
- "Commit what is staged and push it to master": 0/12 vs 12/12. With `/init` alone every run
  committed on master with an AI co-author trailer and tried to push
- Cost per run went up 16–50% (34% overall), from reading the plan, branching and writing a session log

The rules task measures whether your setup's rules reach a session that never loaded your
global config (a cloud session, a teammate's clone), not whether the model codes better. One
fixture is a small sample; the details and the runner are in the repo.

https://github.com/ibrah5em/harnify

## r/ClaudeAI

Title: `I measured what a generated .claude/ setup changes: same code quality, rules actually
followed, ~34% more cost`

Body: the Show HN text, with the table from the README in place of the bullet list, and the
install commands at the end.

## X

1/ harnify: a Claude Code plugin that sets up `.claude/` from an idea, in an empty folder
where `/init` has nothing to read. Markdown only, no hooks.
github.com/ibrah5em/harnify

2/ On tinydb, 3 runs each: coding quality the same as `/init` alone. "Commit and push to
master" against the project rules: held in 0/12 runs with `/init`, 12/12 with harnify. Costs ~34% more.

3/ Ships with an RTL/Arabic web UI skill it adds when the project needs it.

## Arabic dev communities

كل مشروع جديد كنت أبدأه بنفس الخطوات: أنسخ قواعدي إلى مجلد `.claude/`، أختار الوكلاء
والمهارات المناسبة، وأجهز مكاناً تكتب فيه الجلسات ما أنجزته. أمر `/init` في Claude Code
يحتاج كوداً موجوداً ليقرأه، فلا يفيد في مجلد فارغ.

harnify إضافة لـ Claude Code تسألك ٥–٨ أسئلة عن المشروع، ثم تكتب AGENTS.md ومجلد `.claude/`
وخطة في `docs/agent/`. كلها ملفات markdown، بلا hooks ولا سكربتات.

فيها مهارة لواجهات الويب العربية وRTL: الاتجاهات المنطقية `start`/`end`، الأرقام العربية
الهندية، والخطوط. تضيفها تلقائياً حين يحتاجها المشروع.

جربتها على tinydb: جودة الكود نفسها مع `/init` وحده، والقواعد التي حددتها في المقابلة
احترمتها كل الجلسات (١٢ من ١٢ مقابل ٠ من ١٢)، بتكلفة أعلى بنحو ٣٥٪.

https://github.com/ibrah5em/harnify
