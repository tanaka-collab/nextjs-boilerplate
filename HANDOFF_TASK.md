# ChatGPT → Codex 指示書

- 状態: `READY`
- 更新日: 2026-11-18 (JST)
- 対象リポジトリ: `tanaka-collab/nextjs-boilerplate`
- タスクID: `AUTOPILOT-SMOKE-20261118-01`
- 目的: SurfaceのChappy × Codex Autopilot v2.1がGitHubのREADY指示を検出し、Codex CLIの実装→独立レビュー→Draft PR作成を完了できるか安全に検証する。
- 対象ブランチ: ローカル監視プログラムが作る `autopilot/task-*` のみ。
- 安全・停止条件: `AGENTS.md` を遵守。機密データ・既存プログラム・環境設定・依存関係・本番環境に触れない。

## 実施内容（小さな無害な動作検証）
1. 新しいMarkdownファイル `docs/AUTOPILOT_SMOKE_TEST.md` を1つだけ作成する（ディレクトリがなければ作成してよい）。
2. 日本語で次の内容を記録する：
   - タイトル「Autopilot 自動開発 動作確認」
   - タスクID `AUTOPILOT-SMOKE-20261118-01`
   - 「この文書はCodex CLIによる自動起動、変更生成、独立レビュー、Draft PR生成の動作確認用です。」
   - 今回は文書のみを作成し、アプリ本体の機能追加・デプロイは行わないこと。
3. ドキュメントの存在と内容を確認する。実際に実施した検証だけを報告する。
4. `CODEX_LATEST.md` の作成・更新、コミット・push・Draft PR作成はローカルのAutopilot監視プログラムが担当する。Codex CLI自身はコミットやPR操作を行わない。

## 受け入れ基準
- `docs/AUTOPILOT_SMOKE_TEST.md` に指示内容が記録されている。
- それ以外の既存ファイルをCodexは変更しない（監視プログラムによる `CODEX_LATEST.md` 更新を除く）。
- 独立レビューで内容・変更範囲・秘密情報の不在を検査する。
- Windows監視プログラムがDraft PRを作成して終了状態を記録する。
- `main` への直接コード反映、PRマージ、本番デプロイ、課金、外部メッセージ送信を行わない。

## 起動方法
このREADYは、責任者が2026-11-18に明示的に依頼したローカルChappy × Codex Autopilotの実動作検証用です。Windowsに登録済みの `UPSTREAM-Chappy-Codex-Autopilot` が検知してCodex CLIを起動することを承認済みです。Codex Cloudの手動起動を指示するものではありません。
