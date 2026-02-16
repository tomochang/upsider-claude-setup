---
description: Gmail未読メールを分類（skip/info_only/meeting_info/action_required）し、自動アーカイブ・カレンダー照合・返信案作成を行う
argument-hint: <triage|check|edit>
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Edit
  - Write
  - AskUserQuestion
---

# /mail - Gmail返信アシスタント

引数: $ARGUMENTS

## 概要

未読メールを自動分類し、不要メールはアーカイブ、会議情報はカレンダーと照合、要返信メールは返信案を作成する。

## 処理フロー

### Step 1: 未読メール取得

```bash
gog gmail search "is:unread -category:promotions -category:social" --max 20 --json
```

### Step 2: 分類

各メールを以下のカテゴリに分類：

| カテゴリ            | 条件                                                     | アクション                   |
| ------------------- | -------------------------------------------------------- | ---------------------------- |
| **skip**            | noreply, notification, alert, 自動送信、Slack/GitHub通知 | 自動アーカイブ（表示しない） |
| **info_only**       | CCで受信、社内共有、レシート/領収書                      | サマリー表示のみ             |
| **meeting_info**    | 会議招待、日程確定通知、場所・リンク共有                 | カレンダー照合＆更新         |
| **action_required** | 直接宛先、質問・依頼を含む、日程調整                     | 返信案作成                   |

### Step 2.5: meeting_info の自動処理

**会議情報を含むメールを検知したら、カレンダーと照合して不足情報を補完する。**

#### 検知キーワード

```
Teams, Zoom, Meet, WebEx, 会議リンク, 参加URL, 招待,
場所:, @, 会議室, ビル, 階,
.ics, invite.ics, calendar
```

#### 処理フロー

1. **メールから情報抽出**
   - 日時（Subject や本文から）
   - 会議リンク（Teams/Zoom/Meet URL）
   - 場所（住所、ビル名、会議室）
   - 会議タイトル

2. **カレンダー照合**

   ```bash
   # 該当日時付近のイベントを検索
   gog calendar events --from <日付> --to <日付+1> --all --max 30
   ```

   - タイトル or 参加者で既存イベントを特定

3. **差分チェック＆更新**
   | カレンダーの状態 | アクション |
   |-----------------|-----------|
   | イベントなし | ユーザーに報告（要確認） |
   | イベントあり・リンクなし | リンクを追加 |
   | イベントあり・場所なし | 場所を追加 |
   | イベントあり・情報完備 | スキップ |

4. **更新実行**

   ```bash
   gog calendar update <calendar> <eventId> \
     --location "場所" \
     --description "会議リンク: https://..."
   ```

5. **処理後アーカイブ**
   - 情報補完が完了したメールは自動アーカイブ
   - カレンダーにイベントがない場合のみユーザーに報告

### Step 3: action_required のみ処理

1. **送信者コンテキスト取得**
   - `private/miyagi_relationships.md` から関係性・過去のやり取りを確認

2. **日程調整キーワード検知**

   ```
   日程, 面談, ミーティング, 打ち合わせ, 打合せ, MTG,
   お時間, ご都合, スケジュール, 候補日, 候補, いつ,
   お会い, 訪問, ご面談, 会議, アポ
   ```

   → 検知したら `gog calendar events --today --all --max 30` + 14日分の空き確認

3. **返信案生成**
   - 署名: MIYAGI_SIGNATURE
   - トーン: `SOUL.md` の「対・外部」参照
   - 日程調整: 平日9-18時のみ、土日除外

### Step 4: ユーザーに提示

各 action_required メールについて：

- 元メールのサマリー（From, Subject, 要点）
- 返信案
- 選択肢: 「送信」「編集して送信」「スキップ」

### Step 5: 送信

承認されたら：

```bash
gog gmail send \
  --reply-to-message-id "<messageId>" \
  --to "<送信先>" \
  --body "<返信本文>"
```

**重要**: `--reply-to-message-id` を必ず指定（スレッド維持）

### Step 6: 送信後処理（必須・省略禁止）

**メール送信したら、以下をすべて実行するまで完了にしない。**

#### 6.1 カレンダー登録

```bash
# 日程が確定した場合
gog calendar create MIYAGI_CALENDAR_ID \
  --summary "相手名MTG（目的）" \
  --from "YYYY-MM-DDTHH:MM:00+09:00" \
  --to "YYYY-MM-DDTHH:MM:00+09:00"
```

- 日程候補を提示した場合 → すべて `[仮]` で登録
- 確定したら → 不要な仮予定を削除

#### 6.2 relationships.md 更新

```
private/miyagi_relationships.md の該当人物セクションに追記：
- MM/DD やり取り内容（例: 「2/3 MTG承諾返信 → 2/19 15:00確定」）
```

#### 6.3 todo.md 更新

```
private/miyagi_todo.md に反映：
- 「直近の予定」テーブルに予定追加
- 「日程調整」ステータスを「完了」に更新
```

#### 6.4 git commit & push

```bash
cd ~/clawd && git add -A && git commit -m "fix: メール対応（相手名・内容サマリー）" && git push
```

#### 6.5 処理済みメールをアーカイブ

```bash
gog gmail thread modify "<threadId>" --remove "INBOX,UNREAD" --force
```

**この5ステップを1セットで実行。途中で止めない。**

---

## 分類の詳細ルール

### skip（自動スキップ）

- From に `noreply`, `no-reply`, `notification`, `alert` を含む
- From に `@github.com`, `@slack.com`, `@jira`, `@notion.so` を含む
- Subject に `[GitHub]`, `[Slack]`, `[Jira]` を含む

<!--
[要カスタマイズ] 宮城さん固有のスキップ対象をここに追加:
例:
- From が `@example.com`（不要な通知）
-->

### info_only（情報共有）

- To/CC で自分がCC
- From が `support@` で、かつ自分が送った問い合わせへの返信
- Subject に `receipt`, `領収書`, `レシート` を含む

### action_required（要返信）

- 上記に該当しない
- かつ、To で自分が直接宛先
- または、質問（`?`, `？`, `いかがでしょう`, `ご確認ください`）を含む

---

## 出力フォーマット例

```
## 未読メール確認結果

### スキップ (3件) → 自動アーカイブ済み
- GitHub <notifications@github.com> - [repo] PR merged
- Slack <no-reply@slack.com> - New message in #general

### 情報のみ (1件)
- Anthropic <invoice@...> - Your receipt #2718-8582

### 要返信 (1件)

#### 1. 田中太郎 <tanaka@example.com>
**件名**: ミーティングの件
**受信**: 2026-02-06 14:30
**要点**: [メール内容の要約]

**返信案**:
お世話になっております。MIYAGI_SIGNATURE です。

[返信本文]

MIYAGI_SIGNATURE

→ [送信] [編集] [スキップ]
```
