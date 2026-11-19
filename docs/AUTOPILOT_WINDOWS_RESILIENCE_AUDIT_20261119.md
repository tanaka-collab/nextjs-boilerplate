# Chappy Autopilot Windows Resilience Audit

- **Canonical task:** `AUTOPILOT-WINDOWS-RESILIENCE-20261119-01`
- **Task source:** `tanaka-collab/nextjs-boilerplate`, `autopilot-control/HANDOFF_TASK.md`
- **Source status at inspection:** `READY`
- **Source blob SHA:** `218f7a57fb1e62008837d35bf085a4d754c29470`
- **Task content SHA-256:** `4349fae9f405838119da5c315e33d8424cb5e572fc228f9422c9ef24606f0a63`
- **Audit snapshot:** 2026-11-19 18:14 JST (Windows local time; initial and follow-up readbacks)
- **Scope:** local Windows Autopilot and its dedicated Recovery task only. No application code, `main`, unrelated Windows task, Sendnav job, Vercel configuration, or deployment was changed.

## Access and source of truth

Local Windows access was confirmed on the requested Surface Laptop 13 environment: Windows 10.0.26300, ARM64. The canonical task was fetched from the GitHub `autopilot-control` branch; its status was `READY`. The task requires exactly one sanitized audit document in this repository and one Draft PR to `main`.

`main` was `99fe615aab9f9fe2831fcc0f9aee54b42020a2e6` both locally and remotely at inspection. The audit is being prepared on `autopilot/task-4349fae9f405`, whose isolated worktree starts at that exact commit. The original configured `nextjs-boilerplate` worktree remains on `autopilot/task-30790788d1f4` with an existing untracked audit document. Its local state records task hash `30790788d1f4a3b9a8ebffb3c567bfc14c1b9118f339231d9f0b766e1d214094`, status `blocked`, and retry count 0. This is not the current canonical task hash. The runner's dirty-worktree guard reports that it will not overwrite the existing work. That old worktree and document were left untouched; the current task was isolated by its content hash instead.

## Live scheduler and heartbeat evidence

The scheduler snapshot below was read at 18:14:46 JST; initial state was captured at 18:03:32 JST:

| Component | Observed state | Registered behavior and result |
| --- | --- | --- |
| `UPSTREAM-Chappy-Codex-Autopilot` | `Running`; last run 13:21:31 JST; result `0x41301` (running) | Logon trigger; `IgnoreNew`; no execution time limit; 3 retries at 5-minute intervals; `StartWhenAvailable=False`. The existing runner was not stopped or restarted. |
| `UPSTREAM-Chappy-Codex-Autopilot-Recovery` | `Ready`; last run 18:14:12 JST; result `0x0`; next run 18:19:12 JST | Logon trigger and daily trigger repeating every 5 minutes; `IgnoreNew`; 2-minute execution limit; 3 retries at 1-minute intervals; `StartWhenAvailable=True`. Its action and triggers were inspected; task XML was exported before local hardening. |

At the initial 18:03:32 JST readback, health was `degraded` at cycle 94, with 4 repositories checked and 1 error. At the 18:14:46 JST follow-up, health had completed cycle 99: it was `degraded`, with 4 repositories checked, 1 error, and a 120-second poll interval. The latest completed sample at 18:14:13 JST reported scheduler `Running`, health `degraded`, cycle 99, 4 repositories checked, 1 error, and heartbeat age 54 seconds. The Recovery task completed successfully at 18:14:12 JST (`0x0`) and was next due at 18:19:12 JST. The one recurring repository error is consistent with the old configured worktree's dirty-worktree refusal; no repository names or raw log text are copied here. D: was mounted with 240.5 GB free at the follow-up snapshot.

The main worker was therefore alive, but the canonical task was not being processed by that old configured worktree. No task definition was changed. The Recovery task ran the updated watchdog successfully and emitted a compact sample. The next logon will also trigger this existing bounded self-check; an actual Windows restart/logon has not been performed.

## Local hardening and backups

Before editing the dedicated local Autopilot files, reversible backups and exact task XML exports were saved under `storage-maintenance/chappy-autopilot/pre-resilience-hardening-20261119-173857/`. The backup set contains the prior `autopilot.py`, `test_autopilot.py`, `watchdog.ps1`, `health.json`, and XML for both dedicated tasks; a manifest records the backup hashes. No raw log, credentials, configuration file, state file, database, or repository worktree was copied into the backup. No global execution policy or Windows setting was changed.

Local-only changes:

- `autopilot.py` now rotates `autopilot.log` at 1 MiB and retains two generations, redacts common secret assignments before truncation, and uses a sanitized excerpt for top-level fatal exceptions.
- `test_autopilot.py` has regression coverage for assignment redaction and sanitized fatal-error logging.
- The dedicated `watchdog.ps1` now writes allowlisted health/scheduler fields to a bounded JSONL sample under D: during scheduled runs, rotates at 256 KiB with two generations, classifies missing/invalid/stale health (threshold: max of 300 seconds and three poll intervals), and requires `-DryRun` when `-TestState` is used. On simulated unavailable storage it fails closed and writes no fallback to C:.

The Python runner was already active when its files were edited; it has not reloaded the changed Python module. The logger changes are therefore verified by isolated tests and will apply to the runner only on its next normal start. The PowerShell Recovery task did execute the changed watchdog. The task definitions themselves were not modified.

One initial isolated rotation probe accidentally appended a single benign synthetic marker to the live log before the probe was corrected to use a temporary log. It did not rotate, clear, or expose existing log contents. This is disclosed here; no raw line is reproduced.

## Resilience test inventory

| Case | Result | Evidence and limit |
| --- | --- | --- |
| 1. Start-from-stopped and logon/startup behavior | **SIMULATED; actual logon PENDING** | Inspected the existing Logon triggers. In dry-run, a `Ready` task produced `WOULD_START`; a live `Running` task produced `NO_ACTION`. No production task was stopped or started for this test. |
| 2. Single-instance lock | **PASS (isolated)** | The existing live runner held the lock. An isolated second-process probe was blocked, and a separate child released the lock on normal exit. The test that force-kills a child was intentionally excluded. |
| 3. Interrupted work and duplicate publication prevention | **SIMULATED** | Existing unit tests cover recovery only after a fresh review, changed-document rejection, missing/failed review deferral, and no publish on failure. The task ID had no existing open PR at lookup. No artificial crash or real duplicate publication was generated. |
| 4. Watchdog stale-worker detection and recovery decision | **SIMULATED** | Dry-run fixtures covered stale and missing health and the `Ready` recovery decision. The live task stayed `Running`, so the watchdog correctly took no action. No real worker restart was attempted. |
| 5. D: unavailable and recovery | **SIMULATED; recovery after remount PENDING** | A nonexistent `Z:` storage fixture failed closed and wrote no C: fallback. D: stayed mounted; it was not disconnected. Recovery after a real D: outage remains unverified. |
| 6. GitHub/auth/network transient failure | **PASS (mocked)** | Unit tests passed for three bounded GitHub-auth attempts and refusal to repeat a non-idempotent commit after a network retry condition. No real outage was induced. |
| 7. Stale heartbeat and benign restart | **SIMULATED; actual restart PENDING** | Stale-heartbeat classification and dry-run `WOULD_START` behavior passed. The live worker was left running; actual recovery from a stopped or crashed process was not exercised. |
| 8. Preserve Codex sessions, Sendnav, and unrelated tasks | **PASS (no-impact audit)** | No Codex process, Sendnav job, unrelated task, or session was stopped or edited. Both dedicated task XML files were captured for comparison; task definitions remained unchanged. This is a no-interference check, not a long-duration coexistence test. |
| 9. Exit/error log sanitation | **PASS in isolated tests; live Python runtime PENDING** | Redaction and fatal-exception regression tests passed. The active runner has not reloaded the edited module, so the new logging path has not been verified in the live process. |
| 10. Repeated normal polling | **OBSERVED; health DEGRADED** | Health had advanced to cycle 94 and checked all four configured repositories. One error persisted because the configured worktree is dirty and belongs to an older task hash. This confirms repeated cycles, not healthy completion of the current task. |
| Actual Windows restart and subsequent logon | **PENDING** | No restart or logoff was initiated. The existing logon triggers and bounded Recovery self-check are in place to provide evidence after a user-initiated startup. |
| 24-hour stability window | **PENDING** | Bounded local sampling began at 17:44:13 JST on 2026-11-19. A full 24 hours cannot be claimed before 17:44:13 JST on 2026-11-20 and requires later readback. |

### Test commands and results

- From the local Autopilot folder, a Python `unittest` loader ran modules `test_autopilot` and `test_review_feedback`, excluding only `test_process_lock_blocks_second_process_and_releases_after_crash` because that test deliberately force-terminates a child. Result: **56 tests passed** (`Ran 56 tests in 3.830s; OK`).
- Python AST parsing of the modified Python files: **PASS**.
- Windows PowerShell 5.1 parser check for the watchdog: **PASS**.
- Watchdog dry-run fixtures: **PASS** for Running=`NO_ACTION`, Ready=`WOULD_START`, rejecting `-TestState` without `-DryRun`, stale/missing health classification, allowlisted sample fields, rotation/retention, and simulated unavailable storage with no C: write.
- Supplemental isolated logger-rotation and singleton-lock probes: **PASS**. No force termination, machine restart, task stop, or D: disconnection was used.
- The initial ad-hoc PowerShell probe blocked by the existing policy when it omitted the scheduled task's child-only `-ExecutionPolicy Bypass`; the supported scheduled-task invocation was then used for the dry-run checks. No policy was changed.

## Independent review

**Status: BLOCKED / UNVERIFIED.** An isolated `codex exec --sandbox read-only --ephemeral` review was started with instructions to inspect the report, local source/tests, working tree, backup manifest, and task XML without changes. The reviewer runtime could not launch its local shell, Node, or computer-use tools; each failed before reading the audit evidence with `registered Core launch requires an installed app`. The review session made no file or task changes and did not run tests or use the network. This is an environment-access failure, not a review PASS or a content rejection. The report was manually cross-checked against the available task, scheduler, health, backup, source, and test evidence, but an independent reviewer has not verified it.
## Rollback and pending evidence

The local-only file edits can be restored from the pre-change copies in `storage-maintenance/chappy-autopilot/pre-resilience-hardening-20261119-173857/`. Task XML was exported, but no task setting needs restoration because the definitions were not changed. Keep the old dirty worktree intact. To resolve its blocker, first reconcile the canonical task hash and branch deliberately; do not overwrite its untracked audit document or claim that the currently running process has picked up the new task.

Actual Windows restart/logon evidence and a full 24-hour observation remain **PENDING**. The local watchdog sample only records bounded local health/scheduler fields; no cloud service or continuous API polling was added. This audit does not claim complete recovery, a healthy current task run, or 100% resilience.
