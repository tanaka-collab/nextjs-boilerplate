# Chappy Autopilot 2.0 — GitHub connector smoke test

- Date: 2026-11-20 (JST)
- Purpose: verify that this ChatGPT conversation can write a harmless document through the connected GitHub action, then read it back.
- Scope: isolated branch `chappy-v2-bridge-smoke-20261120` only.
- Exclusions: no changes to `main`, `autopilot-control/HANDOFF_TASK.md`, PR #11, local Windows Autopilot, Codex sessions or production tasks.
- This is **not** a Codex dispatch, GitHub READY transaction, project-specific ChatGPT trigger, Windows intake, independent review or E2E test.
- Result: create and readback must both succeed before marking this connector smoke test PASS.
