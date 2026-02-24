---
name: mail
description: Gmail未読メールを分類・返信案作成・送信し、後続タスクまで完遂する（3層アーキテクチャ）
---

# /mail - Gmail返信アシスタント

未読メールを自動分類し、不要メールはアーカイブ、会議情報はカレンダーと照合、要返信メールは返信案を作成・送信する。

## コマンド

```
/mail              # 未読チェック → トリアージ → 下書き生成
/mail check        # 同上
/mail triage       # 同上
/mail send <to> <subject> <body>  # 送信（検証＋後続タスク自動実行）
/mail draft <messageId>           # 下書き用コンテキスト収集
/mail read <messageId>            # メール本文を読む
/mail status       # 現在のトリアージファイルのステータス表示
```

## アーキテクチャ（3層）

```
┌─────────────────────────────────────────────┐
│ スキル (SKILL.md)                            │
│ - 判断ルール（トリアージ分類、トーン選択）      │
│ - 返信ポリシー、送信後チェックリスト           │
├─────────────────────────────────────────────┤
│ プログラム (scripts/)                         │
│ - mail-draft.sh  → コンテキスト強制収集        │
│ - mail-send.sh   → 送信+検証+ステータス更新    │
├─────────────────────────────────────────────┤
│ データ (private/drafts/)                      │
│ - トリアージファイル（ステータス+後続タスクフラグ）│
│ - relationships.md（人物コンテキスト）          │
│ - memory/YYYY-MM-DD.md（送信ログ）             │
└─────────────────────────────────────────────┘
```

**原則: スキルだけに頼らない。プログラムとデータで担保する。**

## 環境

- **ツール**: `gog` CLI（gogcli）
- **アカウント**: `your-work@example.com`
- **スクリプト**: `scripts/mail-draft.sh`, `scripts/mail-send.sh`
- **時刻**: すべてJST表記（UTC禁止）

---

## 処理フロー

### Phase 1: 未読取得＋トリアージ

```bash
gog gmail search "is:unread -category:promotions -category:social" --max 20 --json --account your-work@example.com
```

#### 既存トリアージファイル確認（必須）

新着取得前に `private/drafts/` 配下に別セッションで作られたファイルがないか確認：
```bash
ls -lt private/drafts/*mail* 2>/dev/null
```
→ 既存ファイルがあればマージする。重複対応を防ぐ。

#### 分類

| カテゴリ            | 条件                                                                      | アクション                   |
| ------------------- | ------------------------------------------------------------------------- | ---------------------------- |
| **skip**            | noreply, notification, alert, 自動送信、Slack/GitHub通知                  | 自動アーカイブ（表示しない） |
| **info_only**       | CCで受信、社内共有、レシート/領収書                                       | サマリー表示のみ             |
| **meeting_info**    | 会議招待、日程確定通知、場所・リンク共有                                  | カレンダー照合＆更新         |
| **action_required** | 直接宛先、質問・依頼を含む、日程調整                                      | 返信案作成                   |

### skip対象

- From に `noreply`, `no-reply`, `notification`, `alert` を含む
- From に `@github.com`, `@slack.com`, `@jira`, `@notion.so` を含む
- Subject に `[GitHub]`, `[Slack]`, `[Jira]` を含む

### meeting_info 自動処理

会議情報を含むメールを検知 → カレンダー照合 → 不足情報を補完。

検知キーワード:
```
Teams, Zoom, Meet, WebEx, 会議リンク, 参加URL, 招待,
場所:, 会議室, ビル, 階, .ics, invite.ics
```

処理: 既存イベント特定 → リンク/場所を補完 → 完了後アーカイブ

#### トリアージファイル出力

`private/drafts/mail-replies-YYYY-MM-DD.md` に以下を生成：

```markdown
# メール返信 — YYYY-MM-DD

## 送信フロー（厳守）
1. `mail-draft.sh <messageId>` でコンテキスト収集
2. 下書き作成・承認
3. `mail-send.sh <to> <subject> <body> [--reply-to <messageId>]` で送信
4. 後続タスクフラグをすべて完了にする
※ すべて完了になるまで次に進まない

## ステータス

| # | 相手 | messageId | 送信 | status | cal | rel | mem | 送信日時 |
|---|------|-----------|------|--------|-----|-----|-----|---------|
| 1 | 山田太郎 | abc123 | - | - | - | - | - | |
```

### Phase 2: 下書き生成

**必ず `mail-draft.sh` を実行してから下書きを書く。**

```bash
bash scripts/mail-draft.sh <messageId>
```

出力内容:
1. **relationships.md** の該当人物セクション
2. **メール本文**（全文）
3. **スレッド内の過去やり取り**
4. **カレンダー空き状況**（日程調整キーワード検知時）

→ この出力を読んでから下書きを作成する。出力なしで下書きを書くことは禁止。

#### 下書きルール

- 署名: ユーザー名
- トーン: SOUL.md参照
- 日程調整: 平日9-18時のみ、土日除外
- **不要な謝罪を入れない**
- **返信は必ず `--reply-to-message-id` でスレッド維持**

### Phase 3: 送信

```bash
bash scripts/mail-send.sh <to> <subject> <body> [--reply-to <messageId>]
```

スクリプトが自動実行すること:
1. 送信（reply-to指定時はスレッド維持）
2. **レスポンス検証**（送信成功確認 + エラーチェック）
3. **ステータスファイル自動更新**
4. 後続タスクリスト表示

### Phase 4: 後続タスク

送信成功後、以下をすべて完了する。

| タスク | 内容 | 自動/手動 |
|--------|------|-----------|
| **status** | ステータステーブル更新 | 自動（mail-send.sh） |
| **cal** | カレンダー仮押さえ（日程関連の場合） | 手動 |
| **rel** | relationships.md やり取り履歴追記 | 手動 |
| **mem** | memory/YYYY-MM-DD.md 送信記録 | 手動 |

**全フラグが完了になるまで次のメッセージに進まない。**
