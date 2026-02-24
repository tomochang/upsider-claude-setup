# Procedure Index

手順メモリの軽量インデックス。retrieve hookはこのファイルのみを読んでマッチングする。

## Format

| id                | name                             | tags                                          | trigger_patterns                                                                  | confidence | path                                              |
| ----------------- | -------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------- | ---------- | ------------------------------------------------- |
| proc-example-001  | Slack DMから日報リンクを取得     | slack, daily-report, dm                       | `日報.*Slack`, `Slack.*DM.*取得`, `{person}.*の日報`                              | 0.6        | by-domain/slack/fetch-daily-report-from-dm.proc.md |
| proc-example-002  | NotionページをMCPで取得          | notion, mcp, page, fetch                      | `Notion.*取得`, `Notion.*開いて`, `Notion.*ページ`                                | 0.5        | by-domain/notion/fetch-page-content.proc.md       |
| proc-example-003  | Notion MCPに直接HTTP接続         | notion, mcp, curl, http, json-rpc, fallback   | `Notion.*MCP.*直接`, `Notion.*curl`, `MCP.*ツール.*使えない`                      | 0.7        | by-domain/notion/notion-mcp-direct.proc.md        |
