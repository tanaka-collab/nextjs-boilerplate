# ChatGPT → Codex 指示書

- 状態: `IDLE`
- 更新日: 2026-11-18 (JST)
- 対象リポジトリ: `tanaka-collab/nextjs-boilerplate`
- タスクID: `AUTOPILOT-V31-SMOKE-20261118-03`
- 目的: 完了済み。v3.1の無人実行テストはGitHub Draft PR #6で検証された。
- 実行承認: 2026-11-18に責任者から依頼されたAutopilot完成検証に含まれる、文書1件のみの無害な動作テスト。
- 作業ブランチ: ローカル監視プログラムが作る `autopilot/task-*` のみ。
- 安全条件: `AGENTS.md` の秘密情報保護・限定変更・停止条件を守る。マージ、追加課金、本番デプロイ、GitHub Actions変更、外部メッセージ送信は禁止。

## 完了記録

- 2026-11-18: Draft PR #6 https://github.com/tanaka-collab/nextjs-boilerplate/pull/6 を確認。独立レビュー PASS、文書1件＋報告書1件、未マージ。
- 本タスクは完了済み。次回の新しい開発指示を受け取るまでは何も実行しない。

## 実施内容（完了済み、再実行禁止）

1. **新規Markdownファイル `docs/AUTOPILOT_V31_SMOKE_TEST.md` を1つだけ作成する**。既存文書と既存アプリコードは変更しない。
2. 内容は以下の4項目を含める。
   - 見出し: `# Autopilot v3.1 無人実行確認`
   - タスクID: `AUTOPILOT-V31-SMOKE-20261118-03`
   - 文: `この文書はChatGPTからCodex CLIへの指示、ファイル生成、独立レビュー、Draft PR作成を人手による復旧なしで検証するためのものです。`
   - 文: `今回の変更は文書1件のみとし、アプリ機能変更、PRマージ、本番デプロイは実施しません。`
3. UTF-8で読み戻し、上記4項目が含まれていることを検証する。ファイル変更が指定された新規Markdown 1件のみであることを確認する。
4. 実施した検証だけを簡潔に報告する。実装担当Codexはコミット・push・PR作成・デプロイを行わない。

## 受け入れ条件

- 独立した読み取り専用Codexレビューで `VERDICT: PASS` を確認した場合のみ、Windows Autopilotが `CODEX_LATEST.md` 更新・コミット・push・`main`向けDraft PR作成を行う。
- 変更対象は `docs/AUTOPILOT_V31_SMOKE_TEST.md` とWindows監視プログラムが更新する `CODEX_LATEST.md` の2件に限定する。
- 新しい指示は `autopilot-control` ブランチの本書を正とし、`main` の `HANDOFF_TASK.md` は以前の指示として扱う。
- `main` にマージしない。Vercelとの既存連携によりプレビュー環境が生成される場合があるが、本番反映を行わない。
- 失敗時は安全停止と原因記録を行い、レビューを飛ばしてPRを出さない。
