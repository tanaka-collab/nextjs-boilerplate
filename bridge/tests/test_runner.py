import tempfile
import unittest
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'bridge'))
from runner import parse_task, scan_before_push, clean_codex_env, Bridge

REPO = 'tanaka-collab/income-diagnosis'

class TaskTests(unittest.TestCase):
    def test_ready_accepts_unique_valid_id(self):
        task = parse_task(REPO, '- 状態: `READY`\n- タスクID: `TASK-20261118-001`\n- 目的: lint修正\n')
        self.assertEqual(task.task_id, 'TASK-20261118-001')
    def test_idle_never_runs(self):
        self.assertIsNone(parse_task(REPO, '- 状態: `IDLE`\n- タスクID: `TASK-20261118-001`'))
    def test_rejects_invalid_id(self):
        with self.assertRaises(ValueError):
            parse_task(REPO, '- 状態: `READY`\n- タスクID: 未採番\n- 目的: lint修正')
    def test_rejects_unspecified_goal(self):
        with self.assertRaises(ValueError):
            parse_task(REPO, '- 状態: `READY`\n- タスクID: `TASK-20261118-001`\n- 目的: 未指定')
    def test_env_cleans_secrets(self):
        import os
        os.environ['EXAMPLE_TOKEN'] = 'dontsend'
        try:
            self.assertNotIn('EXAMPLE_TOKEN', clean_codex_env())
        finally:
            del os.environ['EXAMPLE_TOKEN']

if __name__ == '__main__': unittest.main()
