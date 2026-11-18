# AI開発・共通受け渡しルール

## 対象
- リポジトリ: `tanaka-collab/nextjs-boilerplate`
- 種別: Next.js開発テンプレート
- 共通手順: `AI_HANDOFF_GUIDE.md`

## 役割
- 責任者（人間）: 目的・優先順位・重要な変更・本番反映の最終承認
- ChatGPT: 指示を整理し `HANDOFF_TASK.md` に記録、Codexの結果・PRをレビュー
- Codex Cloud: 明示的に起動された作業を実装・検証し `CODEX_LATEST.md` と必要に応じ `PROJECT_STATUS.md` に事実を記録

## 守ること
1. 開始時にこのファイルと `HANDOFF_TASK.md`、`PROJECT_STATUS.md` を読む。
2. `HANDOFF_TASK.md` が `READY` で、依頼内容・対象・受け入れ基準が明確な場合にだけ指定タスクを実行する。 `IDLE` なら実行せず状態を報告する。
3. GitHub上の更新だけではCodex Cloudは自動起動しない。ユーザーがPlusの利用枠内で手動開始する。
4. 作業は原則別ブランチで実施し、プログラム変更はDraft PRとして提出する。既存PR、`main`、本番環境を無断変更しない。
5. 実行した検証と未実施の検証を区別し、`CODEX_LATEST.md` を更新する。長いチャット履歴よりGitHub上の最新ファイルを優先し、矛盾は報告する。
6. 無関係なファイル・環境・ブラウザウィンドウを勝手に変更しない。重要な意思決定は責任者に確認する。
7. OpenAI APIキーの発行・API課金型GitHub Actions・追加クレジット購入は許可なく行わない。追加料金なしで運用する。
8. 公開/非公開を問わず、秘密鍵・APIキー・個人情報・求職者情報・機密ログを指示、コミット、PRに書き込まない。
9. エラー時は無限に再試行せず、事実と停止理由を報告する。
10. CodexからChatGPTへ自動通知は行われない。ユーザーがChatGPTへ「結果を確認して」と伝える。
