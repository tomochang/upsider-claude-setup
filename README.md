# Claude Code セットアップテンプレート

Claude Code + Ghostty + tmux の開発環境を自動セットアップ。

## クイックスタート

### Mac — ターミナルで3つコピペするだけ

```bash
# 0. 任意: 配布元を変更する場合だけ指定（未指定ならこのリポジトリ）
export SETUP_REPO_SLUG="<owner>/<repo>"
export SETUP_REPO_REF="<branch-or-tag>"   # default: main
export SETUP_DIR="$HOME/claude-setup"     # default: ~/claude-setup
export AICOS_REPO_URL="https://github.com/tomochang/ai-chief-of-staff.git" # default

# 1. ブートストラップ（Claude CLIインストール + セットアップ手順配置）
curl -fsSL "https://raw.githubusercontent.com/${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}/${SETUP_REPO_REF:-main}/bootstrap-mac.sh" | bash

# 2. Claude を起動
cd "${SETUP_DIR:-$HOME/claude-setup}" && claude

# 3. Claude に伝える（これだけ手入力）
セットアップを開始して
```

### Windows — PowerShellで3つコピペするだけ

**Step 1.** PowerShell を**右クリック →「管理者として実行」**で開く

**Step 2.** 以下をコピペして実行:
```powershell
$env:SETUP_REPO_SLUG = "<owner/repo>"   # optional
$env:SETUP_REPO_REF  = "<branch-or-tag>" # optional
$env:SETUP_DIR       = "$env:USERPROFILE\\claude-setup" # optional
$env:AICOS_REPO_URL  = "https://github.com/tomochang/ai-chief-of-staff.git" # optional
$repoSlug = if ($env:SETUP_REPO_SLUG) { $env:SETUP_REPO_SLUG } else { "tomochang/upsider-claude-setup" }
$repoRef  = if ($env:SETUP_REPO_REF)  { $env:SETUP_REPO_REF }  else { "main" }
irm "https://raw.githubusercontent.com/$repoSlug/$repoRef/bootstrap-win.ps1" | iex
```

**Step 3.** 「準備完了！」と表示されたら、続けて実行:
```powershell
$setupDir = if ($env:SETUP_DIR) { $env:SETUP_DIR } else { "$env:USERPROFILE\claude-setup" }
cd $setupDir; claude
```

**Step 4.** Claude が起動したら入力:
```
セットアップを開始して
```

あとは Claude が全部やります。

セットアップ完了後の標準状態:

- 各ユーザーの GitHub private リポジトリ（`<github-username>-workspace`）を自動作成
- `${WORKSPACE_DIR:-~/clawd}` ワークスペースを初期化し、private repo に接続
- `${WORKSPACE_DIR:-~/clawd}/AGENTS.md` に非エンジニア向けガードレールを自動反映
- `ai-chief-of-staff` を `${WORKSPACE_DIR:-~/clawd}/tools/ai-chief-of-staff` に導入し、主要コマンド（`/mail` `/today` `/slack` `/chatwork`）を配置

---

## 設定リファレンス（`config/`）

実運用で使われている Claude Code の設定パターン集。個人情報・機密情報は除去済み。

### ディレクトリ構成

```
config/
├── global/                          # ~/.claude/ に配置するグローバル設定
│   ├── settings.json                # モデル選択、プラグイン、hook設定
│   └── hooks/
│       └── cmux-notify.sh           # Stop/Notification 通知フック
│
├── project/                         # プロジェクトの .claude/ に配置する設定
│   ├── settings.json                # Hook lifecycle（全6イベント）設定例
│   ├── CLAUDE.md                    # Plan管理、TDD、失敗ログ等のワークフロー
│   ├── SOUL.md                      # エージェントの人格・振る舞い定義
│   ├── SHARED_RULES.md              # 全エージェント共通ルール（Git運用、レビュー、ワークフロー）
│   ├── REVIEW_GUIDELINES.md         # 資料レビューの目的逆算レビュー原則
│   ├── rules/                       # 行動ルール
│   │   ├── self-awareness.md        # LLMの構造的弱点への対策
│   │   ├── parallel-execution.md    # 並列実行の判断基準
│   │   ├── tool-selection.md        # ツール選択の優先順位
│   │   ├── procedure-replay.md      # 手順メモリの再実行ルール
│   │   ├── session-start.md         # セッション開始時の必須読み込み
│   │   ├── calendar-update.md       # エビデンスベースのカレンダー更新
│   │   ├── email-search.md          # 複数アカウント並列検索
│   │   ├── pre-send-checklist.md    # 送信前CC確認チェックリスト
│   │   ├── post-send-checklist.md   # 送信後の後続タスク自動実行
│   │   └── trigger-workflows.md     # トリガーワード → ワークフロー連携
│   └── agents/                      # サブエージェント定義
│       ├── code-reviewer.md         # コードレビュー専門エージェント
│       ├── code-simplifier.md       # リファクタリング専門エージェント
│       └── build-validator.md       # ビルド検証専門エージェント
│
├── skills/                          # スキル（再利用可能なワークフロー）
│   └── mail/
│       └── SKILL.md                 # Gmail 3層アーキテクチャ（判断/実行/データ）
│
└── procedures/                      # 手順メモリ（Procedural Memory）
    ├── CLAUDE.md                    # 手順メモリシステムの説明
    └── INDEX.md                     # 手順インデックス（hookによる自動マッチング）
```

### 設計思想

#### 1. 3層アーキテクチャ（スキル設計）

```
スキル層   → 判断ルール（何をすべきか）
プログラム層 → 実行スクリプト（どうやるか）
データ層   → 状態管理（何が起きたか）
```

スキルだけに頼らない。プログラムとデータで行動を担保する。

#### 2. Hook Lifecycle

| イベント | 用途 |
|---------|------|
| SessionStart | 必須ファイルの読み込み、状態初期化 |
| UserPromptSubmit | 手順メモリのマッチング、強制プロトコル |
| PreToolUse | タスク実行前のセットアップ |
| PostToolUse | タスク完了後の処理 |
| Stop | 通知、ログ記録 |
| SessionEnd | クリーンアップ |

#### 3. 失敗ログ駆動の改善

Claudeが失敗するたびにCLAUDE.mdの失敗ログに記録。同じ失敗パターンを繰り返さないための仕組み。

#### 4. 手順メモリ（Procedural Memory）

成功したツール操作パターンを `.proc.md` ファイルに永続化。hookが自動でマッチングし、類似タスク実行時にサジェスト。

---

## セキュリティ

このリポジトリは public です。`curl | bash` に不安がある場合は、先にスクリプトを確認できます:

```bash
# Mac: ダウンロードしてから中身を確認 → 実行
curl -fsSL "https://raw.githubusercontent.com/${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}/${SETUP_REPO_REF:-main}/bootstrap-mac.sh" -o /tmp/bootstrap.sh
cat /tmp/bootstrap.sh   # 中身を確認
bash /tmp/bootstrap.sh
```

固定バージョンで実行したい場合（推奨）:

```bash
# main ではなくコミットSHAを固定して取得する
PINNED_SHA="<commit-sha>"
curl -fsSL "https://raw.githubusercontent.com/${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}/${PINNED_SHA}/bootstrap-mac.sh" -o /tmp/bootstrap.sh
bash /tmp/bootstrap.sh
```

## ファイル構成

| ファイル | 役割 |
|---------|------|
| `bootstrap-mac.sh` | Mac用ブートストラップ（Claude CLI + ワークスペース作成） |
| `bootstrap-win.ps1` | Windows用ブートストラップ（Claude CLI + ワークスペース作成） |
| `SETUP_AGENT.md` | Claude が読んで自動実行するセットアップ手順（= CLAUDE.md） |
| `GLOBAL_CLAUDE_MD.md` | グローバル `~/.claude/CLAUDE.md` テンプレート |
| `dynamic-product-architect-v5.2-ja.md` | Dynamic Product Architect メソドロジー |
| `git-auto-sync.sh` | ワークスペースの自動 commit / push スクリプト |
| `mail-command.md` | `/mail` カスタムコマンド（Gmail返信アシスタント） |
| `slack-app-manifest.yaml` | Slack App 作成用 Manifest |
| `versions.env` | ツールバージョン定義 |
| `config/` | **実運用の設定パターン集**（個人情報除去済み） |

## 配布前の準備

### OAuth運用方針（固定）

- Google OAuth クライアントは **ユーザーごとに作らない**
- 以下の **共通1クライアント** を使う:
  - `<ORG>-Claude-Setup-Prod`

### 配布ファイル

Slack の `#private_ai_pdm` 固定投稿に以下を置く:

- `<ORG>-Claude-Setup-Prod.json`（Prodクライアント）

セットアップ中に Claude はこのファイルを既定値として案内する。

### 運用ルール（最低限）

- 固定投稿は「閲覧権限ありメンバーのみ」に限定
- 退職・権限変更時は投稿を差し替え、旧ファイルを削除
- 漏洩疑い時はクライアントシークレットを即再発行し、固定投稿を更新

**このリポジトリに secret を含めないこと。**

## 所要時間

| 条件 | 目安 |
|------|------|
| 開発者（Xcode CLT + Homebrew 済み） | 10分 |
| 非エンジニア（ゼロから） | 15-20分（Xcode CLT待ち含む） |
