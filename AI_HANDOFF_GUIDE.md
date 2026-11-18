# ChatGPT × Codex Cloud × GitHub Free 共通運用ガイド

このリポジトリのコードや関連開発は、チャット間の長いコピペを避けるため、GitHub上の固定Markdownファイルで引き継ぎます。

## ChatGPTでの依頼
「`tanaka-collab/nextjs-boilerplate` の `AGENTS.md`、`HANDOFF_TASK.md`、`PROJECT_STATUS.md` を確認して、このプロジェクトの続きを進めて」と依頼する。ChatGPTは承認済みの新しい作業を `HANDOFF_TASK.md` に記録する。

## Codex Cloudでの開始
ChatGPT Plusに含まれる利用枠内でCodex Cloudを開き、このリポジトリを選ぶ。「`AGENTS.md` と `HANDOFF_TASK.md` を読んで、READYのタスクだけ実行。終了後は `CODEX_LATEST.md` に記録し別ブランチ・Draft PRで報告」と短く指示する。

## ChatGPTでの結果確認
「`tanaka-collab/nextjs-boilerplate` の最新の `CODEX_LATEST.md` と新しいPRを確認して」と依頼する。ChatGPTがGitHubから差分と報告を確認し、完了・未確認・次の判断を整理する。

## 限界
- 別のChatGPTチャットへ自動注入・自動同期はされない。毎回リポジトリを指定すれば同じ最新ファイルを参照できる。
- GitHub更新だけでCodexは起動しない。Codexの完了でこのChatGPT会話が自動的に始まるわけでもない。
- APIキーの登録・OpenAI API課金・GitHubの有料契約はこの方式には不要。ただし既存のChatGPT Plus契約とその利用枠は必要。
- このリポジトリは`public`。機密情報・秘密鍵・個人情報をコミットしない。
- `main` の変更・PRマージ・本番デプロイ・課金・外部送信は責任者の事前承認を得る。
