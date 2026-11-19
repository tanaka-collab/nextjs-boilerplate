# Chappy Autopilot Windows Resilience Audit

- **Canonical task:** `AUTOPILOT-WINDOWS-RESILIENCE-20261119-01`
- **Task source:** `tanaka-collab/nextjs-boilerplate`, `autopilot-control/HANDOFF_TASK.md`
- **Source status at inspection:** `READY`
- **Source blob SHA:** `218f7a57fb1e62008837d35bf085a4d754c29470`
- **Task content SHA-256:** `4349fae9f405838119da5c315e33d8424cb5e572fc228f9422c9ef24606f0a63`
- **Audit snapshot:** 2026-11-19 18:03–19:13 JST (Windows local time); isolated verification at 19:06 JST and hash probe at 19:12 JST
- **Scope:** local Windows Autopilot and its dedicated Recovery task only. No application code, `main`, unrelated Windows task, Sendnav job, Vercel configuration, or deployment was changed.

## Access and source of truth

Local Windows access was confirmed on the requested Surface Laptop 13 environment: Windows 10.0.26300, ARM64. The canonical task was fetched from the GitHub `autopilot-control` branch; its status was `READY`. The task requires exactly one sanitized audit document in this repository and one Draft PR to `main`.

`main` was `99fe615aab9f9fe2831fcc0f9aee54b42020a2e6` locally and remotely. The audit is being prepared on `autopilot/task-4349fae9f405`, whose isolated worktree starts at that exact commit. The original configured `nextjs-boilerplate` worktree remains on `autopilot/task-30790788d1f4` with an existing untracked audit document; its state records hash `30790788d1f4a3b9a8ebffb3c567bfc14c1b9118f339231d9f0b766e1d214094`, status `blocked`, retry count 0. The current canonical task's exact 5,641-byte content hashes to `4349fae9f405838119da5c315e33d8424cb5e572fc228f9422c9ef24606f0a63`; trimming its terminal newline yields the old state hash `30790788d1f4a3b9a8ebffb3c567bfc14c1b9118f339231d9f0b766e1d214094`. A timestamped probe recorded both values. The active runner checks for a dirty worktree before its task hash de-duplication and branch checks, and refused to overwrite the untracked document. The original worktree, document, state file, and configuration were not changed.

## Live scheduler and heartbeat evidence

The first scheduler snapshot was read at 18:14:46 JST; initial state was captured at 18:03:32 JST. A later read-only snapshot was captured at 19:13:23 JST:

| Component | Observed state | Registered behavior and result |
| --- | --- | --- |
| `UPSTREAM-Chappy-Codex-Autopilot` | `Running`; last run 13:21:31 JST; result `0x41301` (running) | Logon trigger; `IgnoreNew`; no execution time limit; 3 retries at 5-minute intervals; `StartWhenAvailable=False`. The existing runner was not stopped or restarted. |
| `UPSTREAM-Chappy-Codex-Autopilot-Recovery` | `Ready`; last run 19:09:12 JST; result `0x0`; next run 19:14:12 JST | Logon trigger and daily trigger repeating every 5 minutes; `IgnoreNew`; 2-minute execution limit; 3 retries at 1-minute intervals; `StartWhenAvailable=True`. Its action and triggers were inspected; task XML was exported before local hardening. |

At the initial 18:03:32 JST readback, health was `degraded` at cycle 94, with 4 repositories checked and 1 error. At 18:14:46 JST, health had completed cycle 99: `degraded`, 4 repositories checked, 1 error, and a 120-second poll interval. At 19:13:23 JST, the latest health file was `degraded` at cycle 122, with 4 repositories checked and 1 error; its timestamp was 19:11:28 JST. The latest bounded sample at 19:09:13 JST captured scheduler `Running`, health `checking`, cycle 121, 0 repositories checked, and 0 errors because it was taken at the start of that polling cycle. The Recovery task completed at 19:09:12 JST (`0x0`) and was next due at 19:14:12 JST. These successive readings distinguish the initial cycle 94 from completed cycle 99 and the later cycle 122; the recurring error remains consistent with refusal to process the configured dirty worktree. D: was mounted and writable during the follow-up tests.

The main worker was therefore alive, but the canonical task was not being processed by that old configured worktree. No task definition was changed. The Recovery task ran the updated watchdog successfully and emitted a compact sample. The next logon will also trigger this existing bounded self-check; an actual Windows restart/logon has not been performed.

## Local hardening and backups

Before the first local hardening, reversible backups and exact task XML exports were saved under `storage-maintenance/chappy-autopilot/pre-resilience-hardening-20261119-173857/`. That set contains the prior `autopilot.py`, `test_autopilot.py`, `watchdog.ps1`, `health.json`, and XML for both dedicated tasks. Before the task-hash correction, an additional exact backup of `autopilot.py` and `config.json` was saved under `storage-maintenance/chappy-autopilot/pre-pr11-repair-20261119-185700/`; its manifest records both SHA-256 values. The config contains repository paths and bounded settings only. No state file, database, or repository worktree was copied. No global execution policy or Windows setting was changed.

Local-only changes:

- `autopilot.py` now rotates `autopilot.log` at 1 MiB and retains two generations, redacts common secret assignments before truncation, and uses a sanitized excerpt for top-level fatal exceptions.
- In the follow-up repair, `process()` now reads the exact `git show` stdout for `HANDOFF_TASK.md` instead of using the general `git()` helper, which strips trailing whitespace. This preserves the canonical task SHA-256, including its terminal newline. The local hash probe and clean bare-repository intake fixture passed.
- `test_autopilot.py` has regression coverage for assignment redaction and sanitized fatal-error logging.
- The dedicated `watchdog.ps1` now writes allowlisted health/scheduler fields to a bounded JSONL sample under D: during scheduled runs, rotates at 256 KiB with two generations, classifies missing/invalid/stale health (threshold: max of 300 seconds and three poll intervals), and requires `-DryRun` when `-TestState` is used. On simulated unavailable storage it fails closed and writes no fallback to C:.

The Python runner started at 13:21:31 JST and remains `Running`; it has not reloaded the changed Python module. The hash fix is therefore verified in isolation and will apply only after a normal later start. The configured worktree remains dirty and on the older task branch, and no in-place cleanup, config switch, or state rewrite was attempted while the runner and feedback scanner were active. The Recovery task did execute the changed watchdog. The task definitions themselves were not modified.

One initial isolated rotation probe accidentally appended a single benign synthetic marker to the live log before the probe was corrected to use a temporary log. It did not rotate, clear, or expose existing log contents. This is disclosed here; no raw line is reproduced.

## Resilience test inventory

| Case | Result | Evidence and limit |
| --- | --- | --- |
| 1. Start-from-stopped and logon/startup behavior | **SIMULATED; actual logon PENDING** | Inspected the existing Logon triggers. In dry-run, a `Ready` task produced `WOULD_START`; a live `Running` task produced `NO_ACTION`. No production task was stopped or started for this test. |
| 2. Single-instance lock | **PASS (isolated)** | The existing live runner held the lock. An isolated second-process probe was blocked, and a separate child released the lock on normal exit. The test that force-kills a child was intentionally excluded. |
| 3. Interrupted work and duplicate publication prevention | **SIMULATED** | Existing unit tests cover recovery only after a fresh review, changed-document rejection, missing/failed review deferral, and no publish on failure. This task already has Draft PR #11; no new PR was created. The isolated fixture used a local bare Git remote and a PR stub, suppressed a same-hash replay, and did not contact GitHub. |
| 4. Watchdog stale-worker detection and recovery decision | **SIMULATED** | Dry-run fixtures covered stale and missing health and the `Ready` recovery decision. The live task stayed `Running`, so the watchdog correctly took no action. No real worker restart was attempted. |
| 5. D: unavailable and recovery | **SIMULATED; recovery after remount PENDING** | A nonexistent `Z:` storage fixture failed closed and wrote no C: fallback. D: stayed mounted; it was not disconnected. Recovery after a real D: outage remains unverified. |
| 6. GitHub/auth/network transient failure | **PASS (mocked)** | Unit tests passed for three bounded GitHub-auth attempts and refusal to repeat a non-idempotent commit after a network retry condition. No real outage was induced. |
| 7. Stale heartbeat and benign restart | **SIMULATED; actual restart PENDING** | Stale-heartbeat classification and dry-run `WOULD_START` behavior passed. The live worker was left running; actual recovery from a stopped or crashed process was not exercised. |
| 8. Preserve Codex sessions, Sendnav, and unrelated tasks | **PASS (no-impact audit)** | No Codex process, Sendnav job, unrelated task, or session was stopped or edited. Both dedicated task XML files were captured for comparison; task definitions remained unchanged. This is a no-interference check, not a long-duration coexistence test. |
| 9. Exit/error log sanitation and task-hash preservation | **PASS in isolated tests; live Python runtime PENDING** | Redaction/fatal-error tests passed. A 5,641-byte canonical task produced raw SHA `4349fae9f405...`; trimming it produced the old state SHA `30790788d1f4...`. The corrected reader passed the isolated intake fixture, but the active runner has not reloaded it. |
| 10. Repeated normal polling | **OBSERVED; health DEGRADED** | Initial cycle 94 at 18:03:32 JST; follow-up cycle 99 at 18:14:46 JST; latest health cycle 122 at 19:11:28 JST, all with 4 repositories checked and 1 error. The error persists because the configured worktree is dirty and on the old task branch. Repeated cycles are verified; healthy completion of the current task is not. |
| Actual Windows restart and subsequent logon | **PENDING** | No restart or logoff was initiated. The existing logon triggers and bounded Recovery self-check are in place to provide evidence after a user-initiated startup. |
| 24-hour stability window | **PENDING** | Bounded local sampling began at 17:44:13 JST on 2026-11-19. A full 24 hours cannot be claimed before 17:44:13 JST on 2026-11-20 and requires later readback. |

### Test commands and results

- **Original run:** The previously reported 56-test result (`3.830s`) and earlier ad-hoc probes are operator-recorded only. Their original commands and per-check timestamps were not retained and remain **UNVERIFIED**; the follow-up run below is not presented as reconstructed historical evidence.
- **Follow-up run:** All times are JST on 2026-11-19. The manifest covers 19:06:15.3172419–19:06:25.5420378 JST and records `result=PASS`, `failed_checks=0`, exact commands, per-check start/end times, exit codes, and captured output. Its SHA-256 is `d9e98bdc1cd38b4b659948e3dc92c8112f4ebb2fd90ba0783aaea91af9143946`. It is stored at `D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\verification.json`. The evidence folder is on D: and contains no production raw logs or credentials.

  - **Python unit suite — 56 passed, 3.955s, exit 0; 19:06:15.3172419–19:06:19.4199291.** It excludes only `test_process_lock_blocks_second_process_and_releases_after_crash`, which force-terminates a child. Captured output: `Ran 56 tests in 3.955s; OK`.

    ```powershell
    python "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\run_unittest_suite.py"
    ```

  - **Python AST — PASS, four files, exit 0; 19:06:19.4587714–19:06:19.5376334.** Captured output: `PYTHON_AST_OK files=4`.

    ```powershell
    python "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\check_ast.py"
    ```

  - **Watchdog parser — PASS, Windows PowerShell 5.1, 1,072 tokens and zero parse errors, exit 0; 19:06:19.5418307–19:06:19.8661391.** Captured output: `{"result":"PASS","parser":"5.1.26100.9974","token_count":1072,"error_count":0}`.

    ```powershell
    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\check_watchdog_parser.ps1" -WatchdogPath "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\watchdog.ps1"
    ```

  - **Watchdog isolated fixtures — PASS, exit 0; 19:06:19.8691446–19:06:22.1709456.** Captured results: Running=`NO_ACTION`; Ready=`WOULD_START`; missing `-DryRun`=exit 2/`TEST_STATE_REQUIRES_DRY_RUN`; missing health=`missing`; stale health=`stale`; allowlisted field set exact; rotation retained two generations; unavailable drive=`STORAGE_UNAVAILABLE` with `no_drive_write=true`. Every fixture path was below the D: evidence folder except the deliberately absent drive.

    ```powershell
    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\run_watchdog_fixtures.ps1" -WatchdogPath "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\watchdog.ps1" -TestRoot "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\watchdog-tests-20261119-190615312"
    ```

  - **READY intake/automation fixture — PASS, exit 0; 19:06:22.1717908–19:06:25.5292815.** Captured summary: task SHA `4349fae9f405...`; branch `autopilot/task-4349fae9f405`; one implementation, one read-only review, and one PR-stub call; same-hash replay suppressed; old-hash dirty fixture refused; untracked sentinel preserved byte-for-byte. The real `process()` path used a local bare Git remote and pushed only there. No real GitHub network or Codex CLI was used.

    ```powershell
    python "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\run_intake_fixture.py" "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253" "D:\RYU_Application data\codex\chappy-autopilot"
    ```

  - **Hash normalization probe — PASS, exit 0; 19:12:02.0521791–19:12:02.0719419.** It read the preserved canonical handoff fixture and recorded 5,641 raw bytes / SHA `4349fae9f405...` versus 5,640 stripped bytes / SHA `30790788d1f4...` in `hash_normalization.json` (SHA-256 `f2a5925a4e06f99267d248779c5f5226d2a45cc1de22fcf16e979b97724f61f5`).

    ```powershell
    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\hash_normalization_probe.ps1" -TaskFile "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\HANDOFF_TASK_fixture.md" -EvidencePath "D:\RYU_Application data\codex\storage-maintenance\chappy-autopilot\pr11-review-evidence-20261119-184253\hash_normalization.json"
    ```

- Two earlier evidence-runner attempts are preserved under `attempt-01/` and `attempt-02/`; they exposed cache-path and isolated-fixture setup errors and are not counted as passing runs. The corrected 19:06 run above passed every check. No production task, state file, or existing repository worktree was changed by these fixtures.
- The scheduled-task watchdog invocation uses child-process `-ExecutionPolicy Bypass`; the machine policy was not changed. No force termination, machine restart, task stop, or D: disconnection was used.

## Independent review

**Codex standalone review: BLOCKED / UNVERIFIED.** The isolated `codex exec --sandbox read-only --ephemeral` reviewer could not launch its local shell, Node, or computer-use tools; each failed before reading evidence with `registered Core launch requires an installed app`. It made no file/task changes and ran no tests. This was an environment launch failure, not a review PASS or a content rejection.

**Read-only local alternative:** PowerShell, Git, the GitHub connector, the local source, scheduler/health files, backup manifest, test outputs, and the current PR diff were readable. The canonical handoff hashes and recorded test outputs were compared with the local evidence files. This verifies the reported test runs and observed state; it is not a second Codex reviewer and does not convert the reviewer-runtime failure into an independent PASS.

The latest ChatGPT review available at the `be1b08c` snapshot was review `5973142031`, submitted at 19:20:06 JST against HEAD `be1b08c993475569bfb7892d7e04761c6473a40d`, with result **BLOCKED**. It confirmed the cycle sequence and the command/time/result entries, then requested the verification-manifest SHA-256 and output summaries in this same document; this revision adds them above. It also stated that the remote reviewer cannot access the local D: source or original evidence, so that part remains **INDEPENDENTLY UNVERIFIED**. At the 19:12 JST process check, no task-specific `codex exec` correction process was active; the existing Codex desktop processes were left untouched. The next same-PR push will generate another synchronize event; that review result is not yet available and remains **PENDING**. The 18:19:52 JST review `5972297569` was **CHANGES_REQUESTED** and its cycle-94/99 finding is reconciled above.

## Rollback and pending evidence

The initial local-only hardening can be restored from `storage-maintenance/chappy-autopilot/pre-resilience-hardening-20261119-173857/`; the task-hash reader and prior config can be restored from `storage-maintenance/chappy-autopilot/pre-pr11-repair-20261119-185700/`. The exact `autopilot.py` and `config.json` hashes are recorded in that backup's manifest. Task XML was exported, and no task setting was changed.

The original dirty worktree, its untracked document, local state, and configuration remain untouched. The active Python runner still has the pre-fix module/config/state in memory; at 19:13 JST it was still Running while health remained `degraded` with one error. The source hash fix passed the isolated fixture, but the live READY task has **not** been resumed and the dirty-worktree blocker is **NOT RESOLVED**. Clearing or redirecting the live worktree while that runner and its review scanner are active could race with their Git/state operations; no process or task was stopped, and no in-memory state was rewritten.

Actual Windows restart/logon evidence remains **PENDING** until the user performs the next normal startup. The 24-hour stability window remains **PENDING** until after 2026-11-20 17:44:13 JST and requires a later readback. No merge, main change, deployment, restart, or logoff was performed. The bounded watchdog sample does not represent a continuous cloud/API check. This audit does not claim live task completion, a healthy current runner, or 100% resilience.
