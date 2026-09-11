# Droopy Agent

A portable workspace for evidence-based functional and UX QA against any client's tracker and staging app. Open **this folder** as its own project — Cursor, Claude Code, or Codex — not nested inside another repo.

Client-agnostic: queue URL, app URL, emails, and spec source are collected at first run. Nothing here is tied to a single product.

## Open in Cursor / Claude Code / Codex

| Tool | Open | First-run | MCP | Skill |
|---|---|---|---|---|
| **Cursor** | File → Open Folder on this directory | Agent introduces itself; **AskQuestion** for setup | Enable `.cursor/mcp.json` servers in MCP settings | `.cursor/skills/droopy-qa/` (symlink to `skills/`) |
| **Claude Code** | `cd` here, run `claude` | Same intro; **numbered list** in chat (see `CLAUDE.md`) | Approve `.mcp.json` (`chrome-devtools`, `figma`) | `.claude/skills/droopy-qa/` and `CLAUDE.md` |
| **Codex** | Open this folder in Codex / `codex` here | Same numbered list from `AGENTS.md` | Trust the project so `.codex/config.toml` loads; or copy those `[mcp_servers.*]` blocks into `~/.codex/config.toml` | `AGENTS.md` + `skills/droopy-qa/SKILL.md` |

Required MCP on every host: **chrome-devtools** and **figma**. Optional GitHub or Mural servers are not in this package — add them yourself if you need them.

## Share this package

Zip the folder **without** secrets or browser state:

- Include rules, skills, docs, scripts, `AGENTS.md`, `CLAUDE.md`, `README.md`, `DESIGN.md`, `.env.example`, `.cursor/mcp.json`, `.mcp.json`, `.codex/config.toml`.
- Exclude `.env`, `.droopy/`, `evidence/` contents, `node_modules/`, Codex session junk under `.codex/` except `config.toml`, and never copy `$HOME/.droopy-agent/chrome-profile`.

Recipients unzip, open the folder in their tool, and complete first-run onboarding.

## First run (per tool)

Do not commit `.env` or `.droopy/`. Those stay local.

### Cursor

1. Open this folder.
2. Send any message.
3. Droopy Agent introduces itself and uses AskQuestion (name, emails, tracker, queue, app URL, spec source, optional token and sheet).
4. Enable this workspace's **chrome-devtools** and **figma** MCP servers. Complete Figma OAuth when prompted.
5. Sign in via SSO in the **one** Chrome window (no passwords). Sessions persist in `$HOME/.droopy-agent/chrome-profile`.

### Claude Code

1. Open this folder and start Claude Code.
2. Approve project MCP from `.mcp.json` when prompted.
3. Send any message. If not onboarded, Claude reads `CLAUDE.md`: verbatim intro, then the numbered interview. Answers go to `.env` and `.droopy/onboarding.json`.
4. Complete Figma OAuth. SSO in the one Chrome window.

### Codex

1. Open this folder. Trust the project so `.codex/config.toml` is loaded (project MCP is ignored while untrusted).
2. Confirm **chrome-devtools** and **figma**. If `/mcp` only lists user-level servers, ask the agent whether the project servers are available, or merge the same blocks into `~/.codex/config.toml`.
3. Send any message. Follow `AGENTS.md` numbered interview if not onboarded.
4. Complete Figma OAuth. SSO in the one Chrome window.

## What it does

1. Uses one persistent Chrome DevTools browser profile.
2. Reloads the configured ticket/review list at the start of each QA session.
3. Reads the story and acceptance criteria, opens the configured QA/app URL, navigates, and tests.
4. Compares the implementation with a linked Figma design through the official Figma MCP when a Figma link exists.
5. If no Figma link exists, checks the ticket, `DESIGN.md`, accessibility, and live UI consistency.
6. Records Pass or Fail against acceptance criteria only. Posts **one** result comment on the ticket; edits that comment if the result was wrong instead of stacking.
7. For failures, creates an evidence-backed defect (four-heading body) unless a matching defect already exists — then log-and-stop. Never overwrite other people's defects.

## Install (after first-run interview)

1. Confirm `.env` has reviewer name, emails, tracker type, `QA_QUEUE_URL`, and `QA_APP_URL`. `FIGMA_API_TOKEN` is optional when Figma OAuth is enabled.
2. Enable **chrome-devtools** and **figma** for your tool (table above).
3. Authenticate Figma through the OAuth prompt once.
4. Start the QA workflow and sign in to the tracker, the app under test, and Microsoft 365 if you use a sheet, in the single Chrome window.

The official Figma MCP uses OAuth, not the personal access token. `FIGMA_API_TOKEN` exists for REST fallback. Never paste OAuth credentials or the token into chat, rules, screenshots, or tracked files.

Optional later: you can add GitHub MCP, Mural MCP, or similar servers to your host's MCP config if your team uses them. They are not required. Tracker and Mural work in the browser by default.

## Authentication and safety

- `$HOME/.droopy-agent/chrome-profile/` is outside this project and must never be shared. It stores this operator's authenticated browser state.
- `.env` is local and ignored.
- The agent may navigate, inspect, and capture evidence automatically.
- Creating a defect and editing a results sheet are external writes. The agent presents a compact pre-write summary and asks only when required information is missing or a consequential field cannot be verified.
- Never submit a defect with guessed dependent dropdown values.
- Loading or hang may be session state, not a product defect: wait, SSO retry, Fail only after retry.
- Persistence tests: after changing filters or state, click the persist-commit control named at onboarding (example label: Load Data) before judging save.

## Setup check

```bash
chmod +x scripts/start-chrome-devtools-mcp.sh scripts/check-setup.sh
./scripts/check-setup.sh
```
