# Defect creation

Complete the tracker create form in this order. If the tracker has cascading dropdowns, they must refresh before the next level is selected.

Use Chrome DevTools on the tracker UI (Jira, GitHub Issues, Azure DevOps, Linear, or other). Do not assume a tracker MCP. Optional GitHub MCP is only if the operator added it later.

## Existing defect: log and stop

This rule gates whether creation happens at all. The rest of this document applies only when no matching defect exists and the bot is authoring a new ticket in the current run.

Do not create a defect because a table, spinner, or empty-while-loading state was still in progress; "not loading" can be session state. File only after waiting for load and a fresh SSO session retry still fails.

Before filing, search the story's linked work and the tracker for an existing defect covering the same failure.

If a matching defect exists:

1. Verify it genuinely covers the observed failure.
2. Record its URL in the results sheet if `QA_RESULTS_SHEET_URL` is set, and in the story comment if the tracker supports comments. If neither exists, record it in `evidence/<ticket-or-id>-result.md`.
3. Take no write action on the ticket. Do not create a duplicate.

Never edit the summary, description, fields, or attachments of a defect the bot did not create in the current run. This holds even when the existing defect is poorly formatted, has a one-line description, or omits the four required headings. Formatting standards in this document apply to defects the bot authors, not retroactively to other people's tickets.

Adding a comment is also a write. Do not comment on another person's defect without explicit user direction.

If the existing defect is materially wrong or incomplete in a way that would mislead a developer, surface that in the final report and let the user decide. Do not act unilaterally. An explicit user request to edit someone else's ticket is a per-request exception and does not become the default.

## Summary

Pattern: **[Location or feature] + [what is wrong]**

The title must identify the defect without requiring the reader to open it. Write it in title case as a specific, observable failure — not a one-word topic or a restatement of the story name.

## Description

A defect must never be filed with a bare one-line description. Compose the body before opening the create form.

The four headings below are mandatory. Use them as bolded headings, in this exact order, with no substitutions and no extra top-level headings:

1. **Steps to reproduce**
2. **Expected result**
3. **Actual result**
4. **Attachment**

### Heading rules

**Steps to reproduce**

- Numbered list starting at 1.
- Step 1 starts with `Navigate to ...`.
- One action per step.
- Bold UI surface names, view names, and feature names inline.

**Expected result**

- Lead with one sentence that states the required behavior.
- When there is more than one specific expectation, follow that sentence with a bullet list of sub-expectations.
- Cite the strongest source of truth: acceptance criteria, the linked Figma frame, or established product behavior. Do not write reviewer preference.

**Actual result**

- Factual observed behavior in prose, not bullets.
- Name the concrete observed values or visual difference.

**Attachment**

- Name the evidence attached (screenshots, exports, or other files). If screenshots are attached, say so.

### Reference example

Use this example as the canonical shape. Reproduce its heading order, numbering, bolding, and list style. Swap in story-specific content; do not collapse it to a single paragraph.

Title:

**Settings Filter Export Displays Undersized Nodes and Misaligned Text**

Description body:

**Steps to reproduce**

1. Navigate to **Settings**.
2. Open **Filters**.
3. Select the **Summary** view.
4. Locate the **Breakdown** visualization.
5. Export the visualization to **PDF**.
6. Compare the exported PDF with the on-screen Summary view.

**Expected result**

The exported PDF should preserve the visual scale and layout of the **Breakdown** shown in the Summary view.

* The nodes and bars should display at a size comparable to the on-screen visualization.
* Labels and percentage values should be properly centered and aligned within their associated visualization elements.
* The overall chart should maintain the same visual proportions and readability as the Summary view.

**Actual result**

In the exported PDF, the decomposition nodes and bars are significantly smaller than they appear in the Summary view.

The associated text and values are also not consistently centered or aligned, causing the exported visualization to look compressed and visually inconsistent with the application.

**Attachment**

(Screenshots attached)

## Fields

Fill only fields the client's tracker requires. Never guess a required field or a cascading option.

Typical mappings when the parent story exposes them:

1. Status: leave the tracker default for a new defect (often To Do or New).
2. Due date: 1–2 business days from creation; never Saturday or Sunday, if the tracker has a due date.
3. Severity: map impact, not urgency.
   - Severity 1: critical outage or blocked major workflow without workaround.
   - Severity 2: important functionality broken or seriously impaired.
   - Severity 3: meaningful functional, data, interaction, or UX defect.
   - Severity 4: minor visual polish such as spacing, typography, alignment, color, border, or stroke.
4. Area / component / project: derive from the story and tested route. Traverse dependent levels if the UI cascades.
5. Assignee: leave automatic or unassigned unless the client requires an assignee.
6. Iteration / sprint / release / environment: inherit the parent review item when available. Do not pick by remembered screen position.
7. Additional fields: do not guess root cause, estimate, labels, or dates.
8. Attachments: attach files from workspace `evidence/` (defect screenshot, plus Figma or spec screenshot when relevant) when the tracker accepts files. Do not invent fields the configured tracker does not have.

## Write path

This path applies only to a defect the bot is creating in the current run. It does not authorize editing a pre-existing ticket.

Create the ticket in the tracker UI so required and cascading fields are selected one level at a time. Do not create the ticket through a REST shortcut that skips those fields.

If the tracker offers a rich-text API **and** this run just created the ticket, you may write the description body through that API so lists and bold headings render natively. Prefer the UI editor when no API is configured (the default: Chrome only). After write, reopen the ticket and confirm:

- All four headings are present.
- Steps are a real numbered list; expected sub-points are a real bullet list.
- No literal `**` markdown leaks into a rich-text field that should have rendered bold.
- Attachments are present.

## Dependent dropdown rule

For any cascading field:

1. Open the parent.
2. Inspect current options.
3. Select the parent value.
4. Wait for the UI to refresh.
5. Inspect the new child options.
6. Select the verified child.
7. Confirm the final displayed value.

Never select by remembered screen position.

## Pre-submit validation

- Failure is reproducible.
- Summary and description agree.
- Description contains all four required headings in order: Steps to reproduce, Expected result, Actual result, Attachment.
- Steps are sufficient for another tester.
- Expected result cites story, Figma, product requirement, or established behavior.
- Actual result is factual and measurable.
- Due date is a weekday when the field exists.
- Severity reflects impact rather than urgency.
- Every required field is complete.
- Evidence is attached and free of unrelated sensitive data.

After creation, reopen the defect and confirm saved fields and attachments before logging its URL.
