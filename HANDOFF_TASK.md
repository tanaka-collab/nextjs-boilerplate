# ChatGPT → Codex 指示書

- 状態: `READY`
- 更新日: 2026-11-18 (JST)
- 対象リポジトリ: `tanaka-collab/nextjs-boilerplate`
- タスクID: `AUTOPILOT-V3-SMOKE-20261118-02`
- 目的: Surfaceに導入したChappy × Codex Autopilot v3.0の第2回エンドツーエンド動作確認。
- 実行承認: このタスクは責任者が2026-11-18に承認したローカルCodex CLI自動実行テスト。Codex Cloudの起動指示ではない。
- 作業ブランチ: Windows監視プログラムが作る `autopilot/task-*` のみ。
- 制限: 機密情報、個人情報、認証情報、既存のアプリコード、依存関係、GitHub Actions、本番設定に触れない。マージや本番デプロイを行わない。

## 実装指示

1. **新規ファイル1件だけ** `docs/AUTOPILOT_V3_SMOKE_TEST.md` を作成する。既存の `docs/AUTOPILOT_SMOKE_TEST.md` は変更しない。
2. UTF-8のMarkdown文書に次の内容を含める。
   - 見出し: `# Autopilot v3 自動開発 動作確認`
   - タスクID: `AUTOPILOT-V3-SMOKE-20261118-02`
   - 本文の一文: `この文書はChatGPTのGitHub指示からCodex CLIの実装、独立レビュー、Draft PR作成までを確認するためのテストです。`
   - `このテストではアプリ本体の変更・本番デプロイ・PRマージを行いません。`
3. 作成した文書が存在し、上記4つの要素を含むことを実際に読み戻して確認する。
4. 既存ファイルを編集せず、作業ツリーに新規Markdown文書1件だけが増えていることを確認する。
5. 実際に行った検証と行っていない検証を正確に報告する。

## 役割と受け入れ条件

- Codex CLIはファイル作成と検証だけを担当し、コミット・push・PR作成・メッセージ送信をしない。
- Windows Autopilot監視プログラムは独立した読み取り専用レビューで `VERDICT: PASS` を確認した場合のみ、`CODEX_LATEST.md` を更新してコミット・pushし、`main`向けのDraft PRを作成・検証する。
- 変更ファイルは、新規文書と監視プログラムが更新する `CODEX_LATEST.md` の計2件を原則とする。
- テスト失敗時には安全に停止し、成功と報告しない。失敗時のGitHub Issue作成はv3監視プログラムの管理下に限る。
- `PROJECT_STATUS.md` にある過去の `IDLE` 記載は古い記録。本件についてはこの `HANDOFF_TASK.md` の `READY` が現在の明示的承認である。ただし、`PROJECT_STATUS.md` 自体は変更しない。
- 新たなAPI課金、追加クレジット購入、`main`への反映、PRマージ、本番デプロイは行わない。GitHub連携による既存のVercelプレビューが動く可能性はある。
