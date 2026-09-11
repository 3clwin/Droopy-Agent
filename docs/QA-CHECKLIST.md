# Story QA Checklist

Values in backticks come from `.env` after onboarding.

## Intake

- Queue at `QA_QUEUE_URL` focused or opened and reloaded at the start of this QA command before reading the list (skip if no queue). If `QA_RESULTS_SHEET_URL` is set, reload that tab before duplicate search or the next empty row; if empty, skip the sheet.
- Auth: sign in where needed with **no passwords**. Work / Microsoft SSO wall → **`QA_WORK_EMAIL`**. Tracker and app under test → **`QA_PRODUCT_EMAIL`** when they differ. Stale app session → log out, return to `QA_APP_URL`, click SSO / corporate login. After SSO, continue. Blocked only if no matching account, SSO missing, or MFA not completed after AskQuestion. If you lack the role the story needs, skip with a reason.
- Item key, URL, summary, due date, iteration, release, area, and environment captured when the tracker provides them.
- Acceptance criteria converted into individually testable assertions.
- Attachments and exact Figma (or other spec) links inspected.
- Existing results-sheet row checked before testing when a sheet is configured.

## Test

- Wait for tables, charts, and pages to finish loading before Pass/Fail; do not file a defect for an in-progress spinner or empty-while-loading. If stale or hung, log out and SSO (no passwords), retry the same screen, and treat non-loading as Fail only after that retry.
- Correct app route and prerequisites established.
- Happy path completed.
- Relevant alternate, empty, loading, error, disabled, hover, and selected states checked.
- Values, labels, precision, sorting, filters, pagination, and totals checked.
- If the story tests persistence of filters or state and `QA_PERSIST_COMMIT_LABEL` is set: modify filter → apply if present → click **`QA_PERSIST_COMMIT_LABEL`** → wait for data to load → then persist checks. If the label is empty, skip persist-commit and note it was not configured.
- Figma-linked states compared at the intended viewport when a Figma URL exists.
- Keyboard, focus, accessible labels, contrast, clipping, and overflow checked.
- Console errors and failed network requests reviewed.
- Export or download artifact opened and inspected when applicable.

## Evidence

- Tested URL, viewport, timestamp, and data state recorded.
- Screenshots saved as `evidence/<ticket-or-id>-<what>.png` using an **absolute** workspace path. Never `/tmp`, never Desktop, never the operator's home. If a write fails, retry that `evidence/` path only.
- Context screenshot and focused defect screenshot captured for failures.
- Expected design or reference captured when relevant.
- When the tracker accepts files, attach from `evidence/` into the defect and/or result comment.
- Screenshot contains no unrelated private information.

## Closure

- Every criterion marked Pass, Fail, or Blocked with evidence.
- Fail: either a defect was created and verified in this run, or an existing matching defect was found, verified to cover the failure, and logged without modification.
- If using a results sheet: correct tab and next empty row; no duplicate story. If `QA_RESULTS_SHEET_URL` is empty, skip the sheet; Pass/Fail is the tracker comment, or `evidence/<ticket-or-id>-result.md` if there is no tracker comment.
- One result comment per ticket when the tracker supports comments: if a posted comment was wrong, edit that same comment we authored this session in place — do not stack a second comment.
- Leftover Chrome tabs closed. Keep only the original working set: queue, app under test, and results sheet if each is configured. Do not leave stray browse pages, defect-search tabs, or extra app routes open. Do not close keep-tabs owned by another run of this same browser.
- Serial run: one review item, one Chrome DevTools process; no second `--userDataDir`, no `--isolated`.
