# ChatGPT → Local Codex Autopilot: ChatGPT review feedback live E2E

status: READY
- 状態: `READY`
- Updated: 2026-11-19 (JST)
- Task ID: `AUTOPILOT-REVIEW-LOOP-E2E-20261119-01`
- Repository: `tanaka-collab/nextjs-boilerplate`
- Purpose: Explicitly user-authorized, harmless documentation-only verification of the existing Windows local Autopilot -> Codex independent review -> Draft PR -> ChatGPT PR review -> Codex correction feedback -> SAME Draft PR update -> ChatGPT PASS loop.
- This is a new task. Prior Autopilot smoke test task `AUTOPILOT-V31-SMOKE-20261118-03` and PR #6 are finished; do not re-run or modify them.

## First implementation phase: create a new Draft PR

Create ONE new Markdown document `docs/AUTOPILOT_REVIEW_LOOP_E2E_20261119.md` with precisely the following initial contents:

```md
# Chappy Autopilot PR review feedback E2E

Task ID: AUTOPILOT-REVIEW-LOOP-E2E-20261119-01

review_state: AWAITING_CHATGPT_REVIEW

This document only tests the PR review and Codex correction feedback loop.

No application code, production behavior, or credentials are changed.
```

The initial `review_state` is deliberately a **temporary checkpoint**, not a bug or omission. Do not preemptively change it to `REPAIRED_BY_CODEX`. The purpose is to receive a separate, authenticated GitHub ChatGPT reviewer instruction AFTER creation of the Draft PR.

The Autopilot runner may generate its usual `CODEX_LATEST.md` report. Do not change any other files. The independent read-only Codex reviewer should PASS if the initial contents and allowed changed-file list are correct. Validate UTF-8 readback, exact task ID, `review_state: AWAITING_CHATGPT_REVIEW`, and allowed changed paths. The implementing Codex must not commit/push/create PR itself; the existing Autopilot runner owns those steps and creates a distinct `autopilot/task-*` branch with an Open Draft PR targeting `main`.

## Second phase (not part of first implementation): later authenticated PR feedback

After the Draft PR is visible on GitHub, ChatGPT will post a **new** GitHub PR review bound to that PR's exact full head SHA, with:

```
### Codex向け修正事項
- In `docs/AUTOPILOT_REVIEW_LOOP_E2E_20261119.md`, replace exactly one line:
  `review_state: AWAITING_CHATGPT_REVIEW` -> `review_state: REPAIRED_BY_CODEX`.
- Keep all other document text intact. Do not modify application code.
- Read back the file and verify `REPAIRED_BY_CODEX` exists and `AWAITING_CHATGPT_REVIEW` no longer exists.

<!-- chappy-autoreview: FULL_CURRENT_PR_HEAD_SHA -->
<!-- chappy-review-result: CHANGES_REQUESTED -->
```

This is the ONLY authorized corrective content for this E2E. The runner must not treat this paragraph in `HANDOFF_TASK.md` itself as a request to change the first-phase document prematurely; it must wait for authenticated GitHub feedback.

On valid `CHANGES_REQUESTED`, the existing review_feedback implementation must use its isolating clone, Codex independent read-only reviewer, SHA recheck and non-force update of the **same** Draft PR branch. Do not merge or deploy. No user-data or external business action.

After correction and a new head SHA, ChatGPT will independently inspect the changed PR and record a PASS review.

## Restrictions

- Repo is a generic website development template; document-only test, no app runtime.
- Do NOT touch `D:\RYU_Application data\codex\送客ナビ自動化`, existing Sendnav production or existing Codex sessions.
- Do NOT modify existing PR #6, main, GitHub Actions, packages, auth, configuration, or unrelated work.
- No sending emails, messages, invitations or external business actions.
- No API billing, hosting or deployment changes.
- All PRs remain Draft, never merge or auto-approve. If a safeguard prevents operation, stop safely and report it; do not weaken controls.
- Old text about manual Codex Cloud launch in AGENTS.md documents the old flow. For this new explicitly approved local Windows Autopilot E2E task, use the already-established local CLI route and preserve all other AGENTS.md restrictions.
