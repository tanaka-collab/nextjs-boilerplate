# ChatGPT WorkによるGitHub PR自動検収（未設定）

ChatGPT WorkでGitHub PR変更をトリガーにしたイベントタスクはPlusでも利用可能な公式機能。ただし通常のChat画面からは設定していない。以下は導入するためのWorkモードへの依頼文。

> tanaka-collab/income-diagnosis、tanaka-collab/nextjs-boilerplate、tanaka-collab/social-lead-aiのGitHub PR作成・変更時に、headがautobridge/で始まるDraft PRだけ調べる。AGENTS.md、DECISIONS.md、HANDOFF_TASK.md、PROJECT_STATUS.md、CODEX_LATEST.md、PRの差分、テスト結果、既存の判断を確認し、安全性と受け入れ基準をレビューする。合格、再修正必要、ユーザー承認待ちのいずれかを報告する。勝手にマージ、課金、本番公開、他者へ送信をしない。

公式説明: https://help.openai.com/en/articles/20001275-chatgpt-work-and-codex

重要: **Work側のイベント設定・動作試験は未実施**。ブリッジはWorkのタスクを作成したり、ChatGPT本体を強制起動する機能を持たない。ChatGPTとCodexが無制限に相互指示する仕組みではない。
