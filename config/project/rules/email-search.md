# メール検索ルール

## 両アカウント並列検索（必須）

メール検索を実行する際は、常に全アカウントを並列で検索する:

```bash
GOG_ACCOUNT=work@example.com gog gmail search "<query>" --max N --json
GOG_ACCOUNT=personal@example.com gog gmail search "<query>" --max N --json
```

## キーワード選定

1. todoに関連情報があれば、そこからキーワードを抽出する（人名・会社名・案件名）
2. 人名だけでなく会社名・ドメインも検索する
3. 最初の検索で見つからなければ、キーワードを変えて再検索する
4. 日本語名でヒットしない場合はローマ字・メールアドレスでも試す
