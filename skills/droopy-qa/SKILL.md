---
name: droopy-qa
description: Tests the next review item from the configured tracker in the live environment against acceptance criteria and Figma when linked, records Pass or Fail, comments on the ticket, and files defects when needed. Use when asked to QA, review, validate, test, or process a story or issue.
---

# Droopy Agent

If `.droopy/onboarding.json` is missing or `.env` still has placeholder values, complete first-run in `AGENTS.md` before any QA (Cursor: AskQuestion via `.cursor/rules/droopy-onboarding.mdc`; Claude Code / Codex: numbered list in `CLAUDE.md` / `AGENTS.md`). Identities and URLs come from `.env`. Never hardcode a person's name, email, queue, or app URL.

This file is the QA source of truth. Cursor and Claude Code load it via symlink; Codex reads it from `skills/`.

Read `AGENTS.md`, `DESIGN.md`, `docs/QA-CHECKLIST.md`, and `docs/BUG-CREATION.md`.

## Guardrails

- Default **serial**: one review item, one Chrome DevTools MCP process. Use this package profile (`$HOME/.droopy-agent/chrome-profile` unless `DROOPY_CHROME_PROFILE` is set). Multiple tabs in that browser are allowed.
- Do not launch a second chrome-devtools server or a second `--userDataDir`. Do not pass chrome-devtools `--isolated` (it wipes SSO).
- Sub-agents must reuse the parent's existing browser. They must not start their own Chrome DevTools server, profile, or `--userDataDir`.
- Each agent tests one item at a time. Do not spawn parallel workers with their own browsers.
- Keep the queue, app under test, and results sheet (if configured) in reusable tabs. If there is no sheet URL, the working set is queue + app only (or app only if there is also no queue).
- Every new QA command (next item, a named ticket, or the rest of the list) starts by focusing or opening `QA_QUEUE_URL` (skip if no queue is configured) and reloading it. Do not reuse a leftover tab's stale session. Only then read the list and pick items. When a results sheet is configured, reload the existing sheet tab before searching for duplicates or the next empty row; do not open another copy. After reload, still keep only the original working set plus whatever the run needs until end-of-run cleanup. Do not reload Figma (headless MCP). Reloading the app is optional unless the story needs a known-fresh app state.
- At the end of every QA run (Pass, Fail, or Blocked), close leftover Chrome tabs. Leave only the original working set: queue, app, and sheet if each is configured. If another run already owns this browser, do not close its keep-tabs.
- Sign in where needed. **No passwords.** Never type, paste, request, or store a password, OTP, or recovery code.
- Never read cookies or `.auth/` / chrome-profile contents into chat.
- On login walls, pick the named SSO account (see Auth). Do not create a new account. Do not use a password form.
- If MFA or device-approval still appears after account selection, pause for the operator (Cursor: AskQuestion; Claude Code / Codex: one numbered question). Do not stall forever and do not skip MFA.
- After successful re-auth, continue the run automatically. Do not treat a completed SSO as Blocked.
- Blocked only if: no matching account in the picker, SSO button missing, or MFA not completed after the user was asked.
- Use the official Figma MCP for exact links; do not open Figma in Chrome unless MCP access fails.
- Specs in Mural, Confluence, or FigJam: use the browser, or a Miro-like MCP only if the operator configured one. Do not assume those servers exist.
- Drive the configured tracker in Chrome DevTools. Follow `QA_TRACKER_TYPE` (GitHub Issues, Jira, Azure DevOps, Linear, other, or none). Use that product's native fields. Do not invent Jira fields on GitHub, or spreadsheet columns when there is no sheet. Do not assume a tracker MCP.
- Ask only when access, required data, or a Pass/Fail-changing ambiguity blocks progress.
- Never mark incomplete testing Pass.
- If you lack the role the story needs, skip with a reason.
- Treat "not loading" as a possible session-state error, not a product defect, until a wait plus a fresh SSO retry still fails.
- Changing filters and clicking apply can update on-screen content immediately; that is not saved. Persistence (navigate away, refresh, tab switch, logout) happens only after the client's persist-commit control named in `QA_PERSIST_COMMIT_LABEL`. If that label is empty, skip persist-commit and record that it was not configured. Do not Fail a persistence story if that control was never clicked.
- Never edit, reformat, re-word, re-attach, or comment on a defect the bot did not create in the current run. If a matching defect already exists, log its URL and stop.
- One result comment per ticket when the tracker supports comments. If the posted comment was wrong (false Fail, missed step, etc.), **edit that same comment** in place. Do not add a second comment or stack Pass then Fail then a correction. Never overwrite other people's comments — only edit comments authored by this operator (comments we authored this session). If there is no comment surface, Pass/Fail is the local `evidence/` note.
- Pass/Fail against acceptance criteria only.

## Workflow

### Auth (SSO, no passwords)

After each required reload (queue, sheet, or app), if a login wall or stale session appears, sign in via SSO. Then continue the workflow.

- **Work / Microsoft SSO** (only if that login wall appears): click the existing account matching **`QA_WORK_EMAIL`**.
- **Tracker and app under test:** choose **`QA_PRODUCT_EMAIL`**.
- **App stale session:** detect expired/empty dashboard, 401, endless loading after auth drop, or a login interstitial. Then use the app's **log out** (or session-end) control, return to `QA_APP_URL`, and click **SSO** / corporate login — not a password form. After SSO, continue the story test.

### 1. Select safely

1. Focus or open `QA_QUEUE_URL` and reload it so newly added items appear. This is the first action of every new QA command. If a login wall appears after reload, complete Auth before reading the list.
2. Determine the current iteration from item metadata when present.
3. Choose the next unreviewed item.
4. If `QA_RESULTS_SHEET_URL` is set, reload that tab and search for the item key and URL. If it is empty, skip sheet lookup.
5. If a sheet row already exists, do not test or write it twice; choose the next item unless the user requested that exact ticket.

### 2. Build the test contract

Capture:

- key, URL, summary, due date, iteration, release, area, and target environment when available;
- every acceptance criterion;
- prerequisite data and navigation;
- attachments, linked work, existing defects, and exact Figma (or other spec) links.

Convert acceptance criteria into individually verifiable assertions. Include functional behavior, data formatting, loading/error/empty states, persistence, regression, and applicable accessibility.

### 3. Resolve design evidence

If a Figma URL exists:

1. Parse its exact file key and node ID.
2. Read that node through Figma MCP.
3. Capture its structure and visual reference.
4. Compare only applicable states and viewport conditions.

If no Figma URL exists, use this order:

1. Ticket acceptance criteria.
2. `DESIGN.md` (client tokens after onboarding; do not invent a brand).
3. Other spec sources from `QA_SPECS_SOURCE` (Mural, Confluence, none).
4. Live component or sibling-screen consistency.
5. Accessibility and platform conventions.

Record conflicts rather than silently choosing a source.

### 4. Test the live environment

Open `QA_APP_URL`, then navigate through the UI or an application-defined route. If the session is stale, follow Auth (log out, then SSO) before testing.

- Wait for tables, charts, and pages to finish loading before judging Pass/Fail. Do not create a defect because a table, spinner, or empty-while-loading state was still in progress.
- If the app looks stale or hung, log out and click SSO (no passwords). Then retry the same screen. Treat non-loading as a product Fail only after that retry still fails.
- Prefer accessibility-tree/DOM inspection.
- Use targeted screenshots for visual findings. Save them under this workspace as `evidence/<ticket-or-id>-<what>.png` using an **absolute** path in that folder. Never `/tmp`, never Desktop, never the operator's home directory. If a write fails, retry that same workspace `evidence/` path only. When the tracker accepts files, attach from `evidence/` into the defect and/or result comment. Keep `evidence/` gitignored except `.gitkeep`.
- Check error and warning console messages.
- List failed XHR/fetch requests without exposing authorization headers.
- Do not retrieve full request details unless the response body is essential; network tooling can reveal sensitive headers.
- Verify each assertion and retain concrete observed values.
- For export stories, open the resulting artifact and compare content, scale, alignment, and readability.
- If the story tests persistence of filters or state and `QA_PERSIST_COMMIT_LABEL` is set: modify filter → apply if present → click **`QA_PERSIST_COMMIT_LABEL`** → wait for data to load → then persist checks. Do not treat the immediate content update as proof the selection saved.

### 5. Classify

- Pass: every applicable assertion positively verified.
- Fail: at least one requirement is contradicted by reproducible evidence.
- Blocked: access, data, or environment prevents a meaningful result. Completed SSO is not Blocked; Blocked only if no matching account, SSO is missing, or MFA was not completed after the operator was asked.

For Fail, search the item's linked work and the tracker for an existing matching defect before creating one. If one exists, verify it covers the observed failure, log its URL, and take no tracker write action on that defect. Four-heading format applies only to defects this run creates.

### 6. Create a defect when needed

If no matching defect exists:

1. Capture current-state evidence and design-reference evidence when applicable.
2. Compose the four-heading description first (`docs/BUG-CREATION.md`). Never file a one-line description.
3. Create the ticket in the tracker UI form. Traverse dependent dropdowns one parent at a time. Do not create the ticket through a REST shortcut that skips required fields.
4. Write the description in the UI (or the tracker's rich-text API only on the ticket this run created). Run the post-write checks in `docs/BUG-CREATION.md`.
5. Attach files from workspace `evidence/` in the UI when the tracker accepts attachments.
6. Validate required fields, including the four description headings.
7. Reopen the ticket and confirm saved fields, four headings, native lists (no literal leaked markdown), and attachments.

If a matching defect exists, verify it covers the observed failure, record its URL, and stop. Do not create a duplicate. Do not edit, reformat, comment on, or re-attach that ticket — including when it is poorly formatted or missing the four headings. If it is materially misleading, report that to the user and wait; do not act unless the user explicitly directs a one-off exception.

### 7. Record Pass/Fail (adaptive)

- If `QA_RESULTS_SHEET_URL` is empty, skip sheet writes entirely. Pass/Fail lives on the tracker comment.
- If there is no tracker comment surface either, write a short Pass/Fail note at `evidence/<ticket-or-id>-result.md` (workspace `evidence/` only).
- If a results sheet is configured, reload the existing sheet tab first. Find the first empty data row. Use the columns that actually exist; do not invent spreadsheet fields. Pass: date, URL, reviewer, Pass when those columns exist. Fail: also observation and defect URL when those columns exist. Never overwrite another worker's row.

### 8. Report

Return:

- item key and result;
- criteria tested and decisive evidence;
- exact Figma node or fallback sources;
- sheet worksheet and row if used (omit if no sheet);
- path of files under `evidence/` when captured;
- defect URL or why no new defect was created;
- blocked or untested scope.

If the tracker supports comments, post one result comment on the ticket. If that comment was wrong, edit the original comment we authored this session in place; do not stack a follow-up. If there is no ticket comment, the local `evidence/` note is the record.

After recording the result, close leftover Chrome tabs. Leave only the original working set.

## Example request

```text
Use the Droopy QA skill to test the next unreviewed item in the queue.
```
