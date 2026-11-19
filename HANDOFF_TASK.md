# ChatGPT → Local Codex Autopilot: Windows resilience verification and hardening

status: READY
- 状態: `READY`
- Updated: 2026-11-19 (JST)
- Task ID: `AUTOPILOT-WINDOWS-RESILIENCE-20261119-01`
- Repository: `tanaka-collab/nextjs-boilerplate`
- Purpose: User explicitly requests finishing remaining Windows startup recovery, watchdog crash recovery, and long-run stability validation of the existing local Chappy Autopilot. This is a NEW task, not a rerun of prior PRs #7 or #9.
- Implementation and independent read-only reviewer: use existing local Codex Autopilot workflow, then create ONE new Draft PR targeting main; do not merge or deploy.

## Scope and deliverable

This is an operational verification of the LOCAL Windows Autopilot already installed on this Surface, NOT a request to change Next.js application code.

Read-only inspect the local Autopilot at `D:\RYU_Application data\codex\chappy-autopilot` and dedicated Task Scheduler tasks named `UPSTREAM-Chappy-Codex-Autopilot` and its Recovery watchdog task. Check actual scripts, trigger types, working directories, the current task state, task last result, startup/re-logon behavior, retry handling, singleton/locking, heartbeat freshness, health.json structure, logs, repository polling, D: availability/error handling and network/GitHub outages. Verify the test harness and existing tests; identify gaps versus claim of automatic startup and robust recovery. DO NOT assume features work merely because a task was registered.

Make necessary safe, minimal hardening for the dedicated Autopilot and its dedicated watchdog only, if applicable, after backups and local tests. Before changing a dedicated scheduled task, export its exact XML and save a reversible local backup (never include secrets or unredacted backups in GitHub). Do NOT change unrelated Windows scheduled tasks, network, security controls, startup programs, or other Codex jobs. Do NOT stop/kill the running production Autopilot or any active Codex session. Do not restart or log off the Surface, and do not unmount/disconnect D:. If repair requires stopping an active runner or elevated action, leave that step blocked with explanation; no unsafe shortcut.

Conduct non-disruptive resilience tests in isolated test fixtures/mocks and, only when provably idle and safe, in dedicated recovery harnesses: (1) start-from-stopped logical process / login/startup trigger correctness, (2) single-instance lock, (3) interrupted task safe resumption with no duplicate PR, (4) watchdog detects and recovers simulated stale worker, (5) D: unavailable and recovery, (6) GitHub/auth/network transient failure with bounded retry, (7) stale heartbeat detection and benign restart, (8) preservation of other Codex sessions and production Sendnav, (9) process exit/error log sanitation, (10) repeated normal operation. Never generate extra real business submissions or touch `D:\RYU_Application data\codex\送客ナビ自動化`.

Distinguish **simulated** reboot/logon tests from an **actual** Windows restart/logon. Do not claim actual restart is verified without real timestamped evidence. Since a real reboot interrupts the user's Windows session, do NOT initiate it. Set up harmless self-check evidence to run at the NEXT user-initiated Windows restart/logon (if safe), without changing unrelated OS settings. Likewise, long-term stability requires real elapsed time; configure or reuse LOCAL lightweight, no-cost health sampling with capped/rotated logs and timestamped evidence, ideally a 24h observation window. Don't add new ChatGPT automations, paid services, background cloud resources, or continuous API calls solely for this. For any case not yet verified in actual elapsed time, mark PENDING, not PASS.

## GitHub deliverable (Draft PR only)

Create and populate precisely `docs/AUTOPILOT_WINDOWS_RESILIENCE_AUDIT_20261119.md` with a **sanitized** factual audit, test inventory, test commands/results (no personal identifiers, tokens or unredacted logs), actual vs simulated status per item, pre-existing and changed dedicated Task Scheduler settings, restoration/rollback instructions, any pending actual-reboot/24h durability evidence, and timestamp of evidence. Note if local changes could not be safely performed. Runner-generated `CODEX_LATEST.md` is allowed. Do NOT add/modify other files in the GitHub PR. Validate that the report accurately labels incomplete items. The independent reviewer should check evidence, not just narrative, and PASS only if all tasks possible without unsafe user impact were performed and pending risks are explicitly marked. Do not invent 100% success.

## Safeguards and follow-up

- Existing `autopilot-control/HANDOFF_TASK.md` for this task must remain authoritative. Status progresses via existing runner. Do not rewrite it from the implementation agent or repeat after completing. Do not rerun earlier E2E projects.
- The dedicated Autopilot may safely test and harden only itself; never interrupt existing Codex jobs, alter other repositories, `main`, ongoing Draft PRs, Vercel, CI/deployment, Google apps, production Sendnav, business messages, login credentials, or data.
- Never force-push, approve, merge, deploy or send messages. Do not create new billable services or tasks.
- If no safe local access, watchdog permission, or accurate evidence is available, report BLOCKED/UNVERIFIED with precise gaps and no false PASS.
- After your safe audit, the runner should create one Draft PR and report a compact machine-readable table of PASS / SIMULATED / PENDING / BLOCKED cases. Keep operational health checks running only if explicitly bounded and low-impact.
