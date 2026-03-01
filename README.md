# UPSIDER Claude Setup

[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows-blue)](#quick-start)
[![Bootstrap](https://img.shields.io/badge/bootstrap-curl%20%7C%20PowerShell-black)](#quick-start)
[![Claude Code](https://img.shields.io/badge/built%20for-Claude%20Code-7B61FF)](https://docs.anthropic.com/en/docs/claude-code)

Claude Code の初期構築を「人が判断、AIが実行」で最短化するセットアップテンプレートです。

> **Before:** 環境構築の手順が散らばっていて、Git/GitHub、Claude設定、コマンド導入、運用ルール整備まで毎回ブレる  
> **After:** `bootstrap` → `claude` → `セットアップを開始して` の3ステップで、実運用可能なワークスペースが立ち上がる

## 何ができるか

- Claude CLI を即利用可能な状態にする（Mac/Windows）
- `~/clawd`（既定）の作業ワークスペースを初期化
- GitHub private repo（`<github-username>-workspace`）を自動作成・接続
- `AGENTS.md` に非エンジニア向けガードレールを追記
- `git-auto-sync` を導入し、自動コミット/プッシュを起動
- `ai-chief-of-staff` を連携し、`/today` `/mail` `/slack` `/chatwork` を投入
- `config/` の実運用テンプレート（global/project/skills/procedures）を参照可能にする

## Quick Start

### Mac（3コマンド）

```bash
# 0) 任意: 配布元/ブランチ/ディレクトリを変える場合だけ指定
export SETUP_REPO_SLUG="<owner>/<repo>"
export SETUP_REPO_REF="<branch-or-tag>"        # default: main
export SETUP_DIR="$HOME/claude-setup"          # default: ~/claude-setup
export WORKSPACE_DIR="$HOME/clawd"             # default: ~/clawd
export AICOS_REPO_URL="https://github.com/tomochang/ai-chief-of-staff.git"  # default

# 1) ブートストラップ
curl -fsSL "https://raw.githubusercontent.com/${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}/${SETUP_REPO_REF:-main}/bootstrap-mac.sh" | bash

# 2) Claude起動
cd "${SETUP_DIR:-$HOME/claude-setup}" && claude

# 3) Claudeに入力
セットアップを開始して
```

### Windows（PowerShell, 管理者）

```powershell
# 0) 任意: 配布元/ブランチ/ディレクトリを変える場合だけ指定
$env:SETUP_REPO_SLUG = "<owner/repo>"
$env:SETUP_REPO_REF  = "<branch-or-tag>"
$env:SETUP_DIR       = "$env:USERPROFILE\claude-setup"
$env:WORKSPACE_DIR   = "$env:USERPROFILE\clawd"
$env:AICOS_REPO_URL  = "https://github.com/tomochang/ai-chief-of-staff.git"

# 1) ブートストラップ
$repoSlug = if ($env:SETUP_REPO_SLUG) { $env:SETUP_REPO_SLUG } else { "tomochang/upsider-claude-setup" }
$repoRef  = if ($env:SETUP_REPO_REF)  { $env:SETUP_REPO_REF }  else { "main" }
irm "https://raw.githubusercontent.com/$repoSlug/$repoRef/bootstrap-win.ps1" | iex

# 2) Claude起動
$setupDir = if ($env:SETUP_DIR) { $env:SETUP_DIR } else { "$env:USERPROFILE\claude-setup" }
cd $setupDir; claude

# 3) Claudeに入力
セットアップを開始して
```

## セットアップ後の到達状態

標準では以下が揃います。

- ワークスペース: `${WORKSPACE_DIR:-~/clawd}`
- private repo: `<github-username>-workspace`（GitHub上に作成）
- 作業用ディレクトリ: `output/`, `private/`, `scripts/`, `tools/`
- `tools/ai-chief-of-staff` を clone/pull
- `~/.claude/commands/` に主要コマンドを配置
  - `today.md`
  - `mail.md`
  - `slack.md`
  - `chatwork.md`
- `skills/schedule-reply/SKILL.md`, `hooks/post-action-check.sh`, `scripts/calendar-suggest.js` を導入
- `scripts/git-auto-sync.sh --daemon` が起動

## なぜこの構成か

### 1. ブートストラップは最小化

`bootstrap-mac.sh` / `bootstrap-win.ps1` は「Claude CLI導入 + `SETUP_AGENT.md` 配置」だけに絞っています。複雑な分岐や認証は Claude 側に寄せることで、失敗時の復旧経路を一本化しています。

### 2. 実行手順は `SETUP_AGENT.md` に集約

長いセットアップを人間のメモで運用すると再現性が落ちます。`SETUP_AGENT.md` に全フェーズを固定し、AIが上から実行する構造にすることで、環境差分を吸収しやすくしています。

### 3. 運用知識は `config/` に分離

導入手順と運用ルールを分けることで、セットアップ完了後の改善（rules/skills/hooks調整）を安全に行えます。

## アーキテクチャ

```text
┌──────────────────────────────┐
│ bootstrap-mac.sh / win.ps1   │
│  - Claude CLI install         │
│  - SETUP_AGENT.md 配置        │
└───────────────┬──────────────┘
                │
┌───────────────▼──────────────┐
│ CLAUDE.md (= SETUP_AGENT.md) │
│  - 環境検出                  │
│  - Git/GitHub連携            │
│  - Workspace初期化           │
│  - ai-chief-of-staff導入      │
│  - 最終検証                  │
└───────────────┬──────────────┘
                │
┌───────────────▼──────────────────────────┐
│ Ready-to-run Workspace                    │
│  ~/clawd + private repo + commands/hooks │
└───────────────────────────────────────────┘
```

## 初回セットアップ後の検証

### Mac

```bash
claude --version
gh --version
gh auth status
cd "${WORKSPACE_DIR:-$HOME/clawd}" && git remote -v
ls -1 ~/.claude/commands | rg "^(today|mail|slack|chatwork)\.md$"
pgrep -af "git-auto-sync.sh"
```

### Windows

```powershell
claude --version
gh --version
gh auth status
$ws = if ($env:WORKSPACE_DIR) { $env:WORKSPACE_DIR } else { "$env:USERPROFILE\clawd" }
cd $ws; git remote -v
Get-ChildItem "$env:USERPROFILE\.claude\commands" | Where-Object { $_.Name -match '^(today|mail|slack|chatwork)\.md$' }
Get-Process | Where-Object { $_.ProcessName -match 'git-auto-sync' }
```

## トラブルシューティング

| 症状 | 原因 | 対処 |
|---|---|---|
| `claude: command not found` | PATH未反映 | 新しいターミナルを開き直し、`~/.claude/bin`（Mac）または検出された`claude.exe`のパス（Windows）がPATHに入っているか確認 |
| `repository not found` | private repo作成権限不足 or org権限不足 | `gh auth status`確認、必要なら`gh auth login`を再実行。組織権限が必要な場合は管理者に付与依頼 |
| `gh repo create` 失敗 | GitHub認証不足 | `gh auth login`後に再実行 |
| `git push` 失敗 | upstream未設定/認証切れ | `git branch --set-upstream-to origin/main main`、または`gh auth refresh` |
| `/today` が使えない | commandファイル未配置 | `~/.claude/commands/today.md` の存在確認。なければ `tools/ai-chief-of-staff/commands/` からコピー |
| `git-auto-sync` が動かない | デーモン未起動 | `"${WORKSPACE_DIR:-$HOME/clawd}/scripts/git-auto-sync.sh" --daemon` を手動実行 |

## セキュリティ

このリポジトリは public です。`curl | bash` が不安な場合は、先にダウンロードして中身を確認してください。

```bash
curl -fsSL "https://raw.githubusercontent.com/${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}/${SETUP_REPO_REF:-main}/bootstrap-mac.sh" -o /tmp/bootstrap.sh
cat /tmp/bootstrap.sh
bash /tmp/bootstrap.sh
```

固定リビジョンで実行する場合（推奨）:

```bash
PINNED_SHA="<commit-sha>"
curl -fsSL "https://raw.githubusercontent.com/${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}/${PINNED_SHA}/bootstrap-mac.sh" -o /tmp/bootstrap.sh
bash /tmp/bootstrap.sh
```

注意:
- シークレットやトークンをこのリポジトリへ保存しない
- OAuthクライアントJSONなどは安全な社内配布経路で管理する

## カスタマイズポイント

### 配布元を差し替える

- `SETUP_REPO_SLUG` を別リポジトリへ変更
- `SETUP_REPO_REF` で branch/tag/SHA を固定

### ワークスペース配置を変更する

- `WORKSPACE_DIR` を指定（例: `~/workspace/team-a`）

### 連携する chief-of-staff を差し替える

- `AICOS_REPO_URL` をフォーク先へ変更

### メールコマンドのみ先行導入する

- `mail-command.md` を `~/.claude/commands/mail.md` へ配置して単体運用可能

## リポジトリ構成

| パス | 役割 |
|---|---|
| `bootstrap-mac.sh` | macOS向けブートストラップ |
| `bootstrap-win.ps1` | Windows向けブートストラップ |
| `SETUP_AGENT.md` | Claudeが実行する本体手順（`CLAUDE.md`として使用） |
| `GLOBAL_CLAUDE_MD.md` | `~/.claude/CLAUDE.md` のテンプレート |
| `mail-command.md` | `/mail` コマンド雛形 |
| `git-auto-sync.sh` | ワークスペース変更の自動commit/push |
| `versions.env` | Node/NVM/Python のバージョン定義 |
| `config/` | 実運用テンプレート（global/project/skills/procedures） |
| `dynamic-product-architect-v5.2-ja.md` | プロダクト設計メソドロジー資料 |

## `config/` の使い方

`config/` はセットアップ後の運用改善用テンプレートです。

- `config/global/`: `~/.claude/` 相当のグローバル設定
- `config/project/`: プロジェクトごとの `.claude/` 設定
- `config/project/memory/failure-log.md`: 失敗ログを `CLAUDE.md` から分離した再発防止ログ
- `config/skills/`: 再利用ワークフロースキル
- `config/procedures/`: 手順メモリ（procedural memory）

段階導入がおすすめです。

1. まずは `settings.json` と基本ルールだけ適用
2. 次に `rules/` と `agents/` を追加
3. 最後に `skills/` と `procedures/` を接続

## 実運用ポリシー（推奨）

- 変更は小さく分けて反映する
- セットアップ手順変更時は `SETUP_AGENT.md` を first-class として更新する
- OSごとの差分を増やしすぎない（可能な限り共通手順へ寄せる）
- 失敗パターンは `config/project/rules/` に再発防止ルールとして追記する

## 関連ドキュメント

- `SETUP_AGENT.md`: 実行フェーズの詳細
- `mail-command.md`: Gmail triageコマンド
- `config/project/CLAUDE.md`: プロジェクト運用ルール
- `config/project/SHARED_RULES.md`: 共通ルール
- `config/project/REVIEW_GUIDELINES.md`: レビュー規約

---

改善提案・運用知見はPR歓迎です。特に「初見ユーザーが詰まるポイント」の報告が最も価値があります。
