import json, subprocess, sys, tempfile, unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'bridge'))
import runner


def g(*args, cwd=None):
    r=subprocess.run(['git',*args],cwd=cwd,capture_output=True,text=True)
    if r.returncode: raise RuntimeError(r.stderr)
    return r.stdout

class MockEndToEnd(unittest.TestCase):
    def test_codex_to_draft_pr_mock(self):
        with tempfile.TemporaryDirectory() as t:
            root=Path(t)
            remote=root/'remote.git'
            source=root/'source'
            g('init','--bare',str(remote))
            g('clone',str(remote),str(source))
            g('config','user.name','Test',cwd=source)
            g('config','user.email','test@example.com',cwd=source)
            g('switch','-c','main',cwd=source)
            text='- 状態: `READY`\n- タスクID: `TASK-20261118-002`\n- 目的: Add tested code\n- 具体的な指示: Add a fixture file\n- 受け入れ基準: Fixture file exists\n'
            (source/'HANDOFF_TASK.md').write_text(text,encoding='utf-8')
            (source/'AGENTS.md').write_text('# Rules\n',encoding='utf-8')
            g('add','-A',cwd=source)
            g('commit','-m','first',cwd=source)
            g('push','-u','origin','main',cwd=source)
            g('--git-dir',str(remote),'symbolic-ref','HEAD','refs/heads/main')
            cfg=root/'cfg.json'
            cfg.write_text(json.dumps({'repositories':['tanaka-collab/nextjs-boilerplate'],'state_dir':str(root/'state'),'poll_seconds':30}),encoding='utf-8')
            bridge=runner.Bridge(cfg)
            task=runner.parse_task('tanaka-collab/nextjs-boilerplate',text.strip())
            original=runner.checked
            def fake_checked(argv,**kwargs):
                if argv[0]=='gh' and argv[1:3]==['pr','create']:
                    return 'https://github.com/example/repo/pull/999'
                if argv[:2]==['git','clone']:
                    argv=[*argv]
                    argv[-2]=str(remote)
                return original(argv,**kwargs)
            def fake_codex(checkout,prompt,answer,*,schema=None,read_only=False):
                if read_only:
                    content=json.dumps({'verdict':'PASS','findings':[],'tests_adequate':True})
                else:
                    (checkout/'fixture.txt').write_text('works\n',encoding='utf-8')
                    (checkout/'CODEX_LATEST.md').write_text('Test: fake mock run only\n',encoding='utf-8')
                    content='implemented'
                answer.write_text(content,encoding='utf-8')
                return content
            with patch.object(runner,'checked',side_effect=fake_checked),patch.object(runner.Bridge,'run_codex',side_effect=fake_codex,autospec=False):
                result=bridge.execute(task)
            self.assertIn('999',result)
            branches=g('--git-dir',str(remote),'branch')
            self.assertIn('autobridge/task-20261118-002',branches)

if __name__=='__main__':unittest.main()
