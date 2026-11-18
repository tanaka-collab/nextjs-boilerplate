# UP-STREAM ChatGPT ↔ Codex Bridge（Surface試験版）

**目標**: ChatGPTからのGitHub指示 → Surfaceで常駐するCodex CLI → コード実装 → Codexによるレビュー・最大3回の修正 → GitHub Draft PR を追加API課金なしでつなぐ。

現段階では **GitHubにソースを作成し、Python基本テスト5件を通過**。Surfaceにインストールされておらず、実際のCodex起動・GitHubプッシュ・PowerShell自動起動は未検証。完全自動化完了と誤認しないこと。

## 一度だけ行うセットアップ

1. このリポジトリの `bridge/` フォルダー、または配布ZIPをSurface上に保存する。
2. Windows PowerShellでそのフォルダーに移動し、`powershell -ExecutionPolicy Bypass -File .\Install.ps1` を実行。インストーラは不足するCLIをwinget/npm経由で導入し、`UPSTREAM-Codex-Bridge` タスクをWindowsのタスクスケジューラに登録する。`-NoInstall` を付けると外部CLIの自動導入をしない。
3. 初回だけGitHubアカウント、Codex CLIのChatGPT Plusアカウントで認証する（**OpenAI APIキーは作成しない**）。追加課金を伴うCodexクレジットを買わない。

デフォルトの設置先・作業データ: `%LOCALAPPDATA%\UPSTREAM\CodexBridge`（内蔵C:）。ユーザーの外付けD:の不安定さを考慮した。既存D:には触れない。Surfaceは蓋を閉じてもスリープしない設定を維持する。

## ChatGPTから仕事を入れる方法

許可済み3リポジトリの main の `HANDOFF_TASK.md` をChatGPTがユーザーの開発指示を受けて更新する。記述例:

```markdown
# ChatGPT → Codex
- 状態: `READY`
- タスクID: `TASK-20261118-002`
- 目的: 具体的な機能改善目的
- 具体的な指示: 対象範囲と実装方法
- 受け入れ基準: 動作とテストの期待結果
- 停止条件: 本番変更、課金、個人情報操作は禁止
```

`IDLE` のままでは動かない。同一タスクIDは一回限り、変更後に同一IDを使い回さない。チャッピーは必ず DECISIONS.md・PROJECT_STATUS.md・AGENTS.md・既存PR を先に読む。

## 実行する処理

- mainの指示書を約90秒間隔で確認。ユーザーがCodexを開く必要はない（常駐プロセスが導入・起動済みの場合）。
- `codex exec` をChatGPT Plusログイン・workspace-write sandboxで実行。GitHub認証等の環境変数は引き渡さない。
- 別のCodex実行によってコードレビューし、指摘があれば最大3周の修正を実施。
- 実際に変更したコードと結果報告を新ブランチにコミット・プッシュし、Draft PRを作成。**mainへのマージ、本番デプロイ、課金、顧客への連絡はしない**。
- 秘密鍵・.env・ワークフロー変更など危険なコミットを拒否。完全な情報漏えい防止は保証できないので、機密プロジェクトには追加の監査が必要。
- 途中中断・失敗時はBLOCKEDとして止め、勝手に同一IDを再実行しない。

## 重要な未実装部分

このブリッジで自動実行されるのは **Codexのレビュー**。**ChatGPT本人による自動レビューではない**。Plus対応のChatGPT WorkにはGitHub PRイベントトリガーがある。Work側で以下の設定と検証が別途必要。

- [Workトリガー設定案](WORK_TRIGGER_SETUP.md)

ChatGPTがレビューコメントを出したら、その内容を自動的にCodexへ再指示する無人の長期ループも未実装。本文の「完成まで作業が止まらない」は現在保証できない。

## 状態確認・停止

```powershell
Get-ScheduledTask -TaskName UPSTREAM-Codex-Bridge
Get-Content "$env:LOCALAPPDATA\UPSTREAM\CodexBridge\bridge.log" -Tail 50
Get-Content "$env:LOCALAPPDATA\UPSTREAM\CodexBridge\state.json"
Stop-ScheduledTask -TaskName UPSTREAM-Codex-Bridge
Disable-ScheduledTask -TaskName UPSTREAM-Codex-Bridge
```

ユニットテスト: `python -m unittest discover -s bridge/tests -v`。テストはコード内の解析・認証情報除去のみで、Windows / Codex 本番結合は未検証。
