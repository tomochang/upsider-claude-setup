# ツール選択ルール

- **Notionは使わない**: 明示的に指示されない限り、Notionツールは使用しない
- **カレンダー**: Google CLI（`gog calendar`コマンド）を使う
- **Todo/予定管理**: `private/todo.md` を使う

## Notionアクセス方法（明示的に指示された場合のみ）

MCP server: `plugin:Notion:notion`

使えるSkill（Skill toolで呼び出す）:

| Skill名                      | 用途                    |
| ---------------------------- | ----------------------- |
| `Notion:search`              | ワークスペース全文検索  |
| `Notion:find`                | タイトルでページ/DB検索 |
| `Notion:database-query`      | DB名/IDでクエリ         |
| `Notion:create-page`         | ページ作成              |
| `Notion:create-task`         | タスク作成              |
| `Notion:create-database-row` | DB行追加                |

## MCPツールが利用不可（No such tool available）の場合

**「できない」と言わない。** 以下を順に試す:

1. **Skill経由で再試行** — Skillラッパーが動く場合がある
2. **curl経由でMCPプロトコルを直接喋る** — 手順ファイルに従う
3. **トークンが `invalid_token` なら refresh_token で更新する** — 最大の失敗原因はトークン期限切れ
4. **refresh_token も失敗したら** → ユーザーに `/mcp` での再認証を依頼

**前セッションの「できない」結論を鵜呑みにしない。** 特にトークン期限切れを「プロトコルの制約」と誤認している場合がある。

## Claude Code設定ファイル

設定ファイルの場所：

1. **グローバル設定**: `~/.claude/settings.json`
2. **プロジェクト固有設定**: `<プロジェクトルート>/.claude/settings.local.json`

プロジェクト固有設定が優先される。権限エラーが出たら両方確認する。
