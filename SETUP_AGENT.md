# 環境セットアップエージェント

あなたは **開発環境セットアップアシスタント** です。
このファイルの手順を **上から順に自分で実行** して、ユーザーの環境を自動構築してください。

---

## 定数

```bash
SETUP_REPO_SLUG=${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}
SETUP_REPO_REF=${SETUP_REPO_REF:-main}
REPO_RAW="https://raw.githubusercontent.com/${SETUP_REPO_SLUG}/${SETUP_REPO_REF}"
WORKSPACE_DIR=${WORKSPACE_DIR:-$HOME/clawd}
SETUP_DIR=${SETUP_DIR:-$HOME/claude-setup}
AICOS_REPO_URL=${AICOS_REPO_URL:-https://github.com/tomochang/ai-chief-of-staff.git}
```

## バージョン定義

`versions.env` から取得する（単一管理）:
```bash
curl -fsSL "${REPO_RAW}/versions.env" -o /tmp/versions.env && source /tmp/versions.env
```

フォールバック値（`versions.env` が取得できない場合のみ使用）:
- **Node.js**: 24.13.0
- **NVM**: 0.40.4
- **Python**: 3.14

以降すべてのコマンドで `$NODE_VERSION`, `$NVM_VERSION`, `$PYTHON_VERSION` 変数を使う。

---

## ルール（厳守）

1. **コマンドは自分で実行する** — ユーザーにコピペさせない。Bashツールで直接実行。
2. **エラーは自分で調査して修正する** — 同じコマンドを2回リトライしない。エラーメッセージを読んでアプローチを変える。
3. **認証が必要な箇所だけユーザーに指示する** — 「ブラウザでここを開いて → こうして → 結果を貼って」の形式で。
4. **各チェックポイントを実行し、失敗したら先に進まない。**
5. **プラットフォーム分岐は自動判定する** — ユーザーに聞かない。Phase 1 の結果を使う。
6. **冪等性を保つ** — `command -v` や `test -f` で既にインストール済みか確認し、済みならスキップ。
7. **3回失敗したら停止してユーザーに状況を報告する。**
8. **待ち時間は並列活用する** — インストール待ちの間にブラウザ作業をユーザーに案内する。
9. **プレースホルダ `{...}` は Phase 0 で収集した実際の値に置換してから実行する。**

---

## Phase 0: 導入 → ハマりポイント説明 → 情報収集

### これから何をセットアップするか（省略禁止・最初に必ず表示）

```
==========================================
 AI 開発環境セットアップ
==========================================

これからセットアップするもの:
  - Claude Code … AIペアプログラマー。コード・レビュー・調査・テストを全部やる
  - Ghostty + tmux … 複数のClaudeを同時に走らせるターミナル環境
  - Slack / Notion / Google連携 … Claudeが直接Slackを読み書き、Notion検索、カレンダー確認できる
  - Dynamic Product Architect … プロダクト開発メソドロジー

所要時間: 約10分
あなたがやること: ブラウザでログイン数回だけ。残りはClaude（私）が全自動でやります。
```

### なぜこれをやるのか（省略禁止・必ず表示）

```
==========================================
 なぜ全員がこの環境を持つべきなのか
==========================================

社内プロダクトは、モックからAPI・DB・認証を備えたフルサービスに
たった1日で進化しました。水野さんの寄与をAIが出したのを見ると、
マジで低いです。つまり、ほぼ全部AIが書いています。

これは特別な話ではありません:
  - Anthropicは自社のプロダクトをClaude Codeで作っています（dogfooding）
  - Y Combinatorの2025年冬バッチ、スタートアップの25%がコードの95%をAI生成
  - 世界のコードの41%はすでにAIが書いています（2024年時点）
  - Anthropic CEO: 「もうコードは書いていない。モデルに書かせて、編集するだけ」

少なくとも社内で使うシステム — 会計ソフト、ワークフロー、HRツール —
であれば、もはや誰でも作れます。ユーザビリティテストもユニットテストも
アーキテクチャもベストプラクティス調査も、良いコンテキストを与えれば
AIが全部やってくれます。

==========================================
 ただし、最も重要なルールがあります
==========================================

AIは「良いコンテキスト」を与えるかが全てです。

例えば銀行サービスは、Accountingチームの
「承認画面で一括承認したくても詳細画面を一々開かないといけなくてだるい」
「金額はカンマ表示で出してくれないとキモい」
というコンテキストが決定的に重要でした。これがあるから良いサービスを
AIは作れます。

つまり、現場に出て業務をやっている、経験のある人にAIを与えるのが
最強ということになります。

営業でお客様に実際に売って、どんな反応をされたか。
サポートでお客様がこういうことに怒っている。
システム障害と戦い、法務で裁判対応し、回収で毎日電話をかけ、
「改善したい」「ここが嫌だ」「こうなったらいいのに」
という感情を具体的に持っている人が、一番偉い。

あなたのその感情は宝物です。
世界で最も価値があるものです。
しかも、今や自分の手で改善できるのです。

「俺の経験や感情をプロダクトにしろ」
そうAIに言えば、こいつらはあなたがほしいものをすぐ作ります。

今日のセットアップは、そのための環境を整えます。
始めましょう。
```

### ハマりポイント（省略禁止）

```
セットアップ前に、知っておいてほしいことが5つあります:

1. パスワード入力時、画面に文字は表示されません。
   見えなくてもそのまま打ってEnterしてください。正常です。

2. Macのパスワードを何度も聞かれます。
   パスワードをどこかにコピーしておいて、聞かれるたびにペースト連打が楽です。

3. 「Googleで確認されていません」という警告が出ますが正常です。
   「詳細」→「安全でないページに移動」で進んでください。

4. Slack Appの設定で「User Token Scopes」と「Bot Token Scopes」を
   間違えやすいです。必ず「User Token Scopes」の方です。
   （今回はManifestを使うので自動設定されますが、念のため）

5. GitHubのprivateリポジトリにアクセスするには管理者に招待してもらう
   必要があります。「repository not found」が出たらアクセス権を確認。
```

### 情報収集（一度に全部聞く）

```
GitHubアカウント未作成の場合は https://github.com/signup で先に作成してください。

セットアップに必要な情報を教えてください:

1. 名前（日本語。メール署名に使います。例: 水野）
2. GitHubユーザー名
3. GitHubに登録しているメールアドレス
4. Claudeサブスクリプション（Pro/Max）でログイン済みですか？（未ログインなら `claude login` を実行します）
5. Googleアカウント（Gmail/Calendar連携用）
```

回答を変数として保持:
- `{USER_NAME}` = 名前（日本語）
- `{USER_NAME_LOWER}` = 名前（ローマ字小文字、ファイル名用）
- `{GITHUB_USERNAME}` = GitHubユーザー名
- `{GITHUB_EMAIL}` = GitHubメールアドレス
- `{USER_EMAIL}` = Googleアカウント
- `{PRIVATE_REPO_NAME}` = `{GITHUB_USERNAME}-workspace`

---

## Phase 1: プラットフォーム検出

```bash
echo "OS: $(uname -s)"
echo "ARCH: $(uname -m)"
sw_vers 2>/dev/null || ver 2>/dev/null || echo "Unknown OS"
df -h / 2>/dev/null | tail -1
```

判定ルール:
- `Darwin` + `arm64` → **Mac ARM** (`BREW_PREFIX=/opt/homebrew`)
- `Darwin` + `x86_64` → **Mac Intel** (`BREW_PREFIX=/usr/local`)
- `MINGW`, `MSYS`, `CYGWIN` → **Windows** (winget使用、Ghostty/tmuxスキップ)

以降すべてのコマンドで `$BREW_PREFIX` を使い分ける。

---

## Phase 2: 基盤ツール

ブートストラップで Homebrew + Claude CLI は済んでいるはず。未インストールなら実行:

### Mac

```bash
# Xcode CLT（未インストールの場合のみ）
xcode-select -p &>/dev/null || xcode-select --install
# → ダイアログで「インストール」を押すよう案内
# → 完了待ちの間に、Claude未ログインなら `claude login` を案内

# Homebrew（未インストールの場合のみ）
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_PREFIX=$([[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")
  grep -q "brew shellenv" ~/.zprofile 2>/dev/null || echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >> ~/.zprofile
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# Claude CLI（未インストールの場合のみ）
command -v claude || { curl -fsSL https://claude.ai/install.sh | bash && export PATH="$HOME/.claude/bin:$PATH"; }

# Claude サブスクリプションログイン（未ログインの場合のみ）
claude login || true
```

### Windows

```powershell
# Claude CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { irm https://claude.ai/install.ps1 | iex }

# Claude サブスクリプションログイン（未ログインの場合のみ）
claude login
```

### チェックポイント 2

Mac:
```bash
brew --version 2>/dev/null | head -1
claude --version
echo "✅ 基盤ツール OK"
```

Windows:
```powershell
claude --version
Write-Host "✅ 基盤ツール OK"
```

---

## Phase 3: Git & GitHub + 【並列】Slack App 作成

### 3.1 Git 設定

```bash
git config --global user.name "{GITHUB_USERNAME}"
git config --global user.email "{GITHUB_EMAIL}"
```

### 3.2 GitHub CLI

Mac:
```bash
command -v gh || brew install gh
command -v git-lfs || brew install git-lfs
git lfs install
```

Windows:
```powershell
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { winget install GitHub.cli --accept-source-agreements --accept-package-agreements }
if (-not (Get-Command git-lfs -ErrorAction SilentlyContinue)) { winget install GitHub.GitLFS --accept-source-agreements --accept-package-agreements }
git lfs install
```

### 3.3 GitHub 認証

```bash
gh auth status 2>/dev/null || gh auth login
```

→ ユーザーに案内:
```
GitHubの認証をします:
1. GitHub.com を選択
2. HTTPS を選択
3. Yes
4. Login with a web browser を選択
5. ワンタイムコードが表示される → ブラウザでコードを入力 → Authorize
```

認証後（Mac のみ）:
```bash
BREW_PREFIX=$([[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")
git config --global credential.https://github.com.helper ""
git config --global credential.https://github.com.helper "!${BREW_PREFIX}/bin/gh auth git-credential"
git config --global credential.https://gist.github.com.helper ""
git config --global credential.https://gist.github.com.helper "!${BREW_PREFIX}/bin/gh auth git-credential"
```

### 3.4 【並列】Slack App 作成（GitHub認証 or brew待ちの間にやる）

**ユーザーに案内（Manifest方式）:**

```
Slack App を作ります:

1. https://api.slack.com/apps を開く
2. 「Create New App」→「From an app manifest」を選択
3. 対象ワークスペースを選択 →「Next」
4. 入力欄を「YAML」タブに切り替え
5. 以下を貼り付け:

display_information:
  name: Claude Code MCP
  description: Claude Code から Slack を操作するための MCP サーバー
oauth_config:
  scopes:
    user:
      - channels:history
      - channels:read
      - chat:write
      - groups:history
      - groups:read
      - im:history
      - im:read
      - mpim:history
      - mpim:read
      - search:read
      - users:read
settings:
  org_deploy_enabled: false
  socket_mode_enabled: false
  token_rotation_enabled: false

6. 「Next」→ 確認 →「Create」
7. 左メニュー →「OAuth & Permissions」
8. 「Install to Workspace」→「許可する」
9. xoxp- で始まるトークンをコピーして貼り付けてください
```

→ トークンを `{SLACK_TOKEN}` として保持。

### チェックポイント 3

```bash
git --version && gh auth status && echo "✅ Git & GitHub OK"
```

---

## Phase 4: Node.js

### Mac

```bash
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

node --version 2>/dev/null | grep -q "v${NODE_VERSION%%.*}" || { nvm install "$NODE_VERSION" && nvm alias default "$NODE_VERSION"; }

if ! command -v bun &>/dev/null; then
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
```

### Windows

```powershell
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  winget install CoreyButler.NVMforWindows --accept-source-agreements --accept-package-agreements
  # nvm-windows は新しいシェルで有効化されるため、PATHを手動追加
  $env:NVM_HOME = "$env:APPDATA\nvm"
  $env:PATH = "$env:NVM_HOME;$env:PATH"
  nvm install 24.13.0
  nvm use 24.13.0
}

if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
  irm https://bun.sh/install.ps1 | iex
}
```

### チェックポイント 4

Mac:
```bash
node --version && echo "✅ Node.js OK"
```

Windows:
```powershell
node --version
Write-Host "✅ Node.js OK"
```

---

## Phase 5: Claude Code 設定

### 5.1 グローバル設定

```bash
mkdir -p ~/.claude
test -f ~/.claude/settings.json || cat > ~/.claude/settings.json << 'EOF'
{
  "model": "claude-opus-4-6",
  "enabledPlugins": {
    "claude-mem@thedotmack": true
  },
  "allowedTools": [
    "WebFetch",
    "WebSearch"
  ],
  "autoUpdatesChannel": "stable"
}
EOF
```

### 5.2 claude-mem プラグイン

```bash
claude plugin install claude-mem@thedotmack
```

→ `Marketplace not found`: `claude --version` 実行後にリトライ。2回失敗 → スキップ。

### 5.3 Codex 設定（AGENTS.md フォールバック）

```bash
mkdir -p ~/.codex
touch ~/.codex/config.toml

# Codex公式設定: AGENTS.md が無い階層で参照するファイル名を追加
if ! grep -q '^project_doc_fallback_filenames' ~/.codex/config.toml; then
  cat >> ~/.codex/config.toml << 'EOF'
project_doc_fallback_filenames = ["CLAUDE.md", ".agents.md"]
EOF
fi
```

---

## Phase 6: MCP サーバー

### 6.1 Notion

```bash
claude mcp add "claude.ai/Notion" --transport sse --url "https://mcp.notion.com/mcp" 2>/dev/null || true
```

### 6.2 Slack

Mac:
```bash
command -v slack-mcp-server || brew install nichochar/tap/slack-mcp-server
SLACK_MCP_PATH=$(which slack-mcp-server)
```

Windows:
```bash
command -v slack-mcp-server || npm install -g @nichochar/slack-mcp-server
SLACK_MCP_PATH=$(which slack-mcp-server || echo "$(npm root -g)/@nichochar/slack-mcp-server/dist/index.js")
```

登録（共通）:
```bash
claude mcp add slack -s user \
  -e SLACK_MCP_XOXP_TOKEN={SLACK_TOKEN} \
  -e SLACK_MCP_ADD_MESSAGE_TOOL=true \
  -- "$SLACK_MCP_PATH"
```

---

## Phase 7: ワークスペース

### Mac

```bash
# 変数
PRIVATE_REPO_NAME="{GITHUB_USERNAME}-workspace"
PRIVATE_REPO_FULL="{GITHUB_USERNAME}/${PRIVATE_REPO_NAME}"
SETUP_REPO_SLUG="${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}"
SETUP_REPO_REF="${SETUP_REPO_REF:-main}"
REPO_RAW="https://raw.githubusercontent.com/${SETUP_REPO_SLUG}/${SETUP_REPO_REF}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/clawd}"

# ワークスペース作成
mkdir -p "$WORKSPACE_DIR/output" "$WORKSPACE_DIR/private" "$WORKSPACE_DIR/scripts"

# 個人privateリポジトリ作成（未作成時のみ）
cd "$WORKSPACE_DIR"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init
fi
if ! gh repo view "$PRIVATE_REPO_FULL" >/dev/null 2>&1; then
  gh repo create "$PRIVATE_REPO_FULL" --private --description "Personal workspace auto-synced from Claude Code"
fi

# origin を個人privateへ接続
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$PRIVATE_REPO_FULL.git"

# 初回push
git checkout -B main
git add -A && git commit -m "initial workspace" --allow-empty
git push -u origin main

# グローバル CLAUDE.md（リポジトリからダウンロード）
test -f ~/CLAUDE.md || curl -fsSL "${REPO_RAW}/GLOBAL_CLAUDE_MD.md" -o ~/CLAUDE.md
mkdir -p ~/.claude
test -f ~/.claude/CLAUDE.md || curl -fsSL "${REPO_RAW}/GLOBAL_CLAUDE_MD.md" -o ~/.claude/CLAUDE.md

# Dynamic Product Architect メソドロジー
test -f "$WORKSPACE_DIR/output/dynamic-product-architect-v5.2-ja.md" || \
  curl -fsSL "${REPO_RAW}/dynamic-product-architect-v5.2-ja.md" -o "$WORKSPACE_DIR/output/dynamic-product-architect-v5.2-ja.md"

# 非エンジニア向けガードレール
if ! grep -q "## Non-Engineer Guardrails" "$WORKSPACE_DIR/AGENTS.md" 2>/dev/null; then
  cat >> "$WORKSPACE_DIR/AGENTS.md" << 'EOF'

## Non-Engineer Guardrails

- 破壊的操作（`rm -rf`, `git reset --hard`, 履歴改変）はユーザーの明示許可なしで実行しない
- 外部送信（メール/Slack投稿/本番デプロイ/公開URL共有）は実行前に必ず確認する
- `credentials*.json`, `.env`, token, secret をGitにcommitしない
- 高リスク変更（DBマイグレーション、権限設定変更、課金リソース作成）は実行前に理由と影響を提示する
- 不明点がある場合は推測で実行せず、選択肢と推奨案を提示して確認する
EOF
fi

# git-auto-sync スクリプト
test -f "$WORKSPACE_DIR/scripts/git-auto-sync.sh" || \
  curl -fsSL "${REPO_RAW}/git-auto-sync.sh" -o "$WORKSPACE_DIR/scripts/git-auto-sync.sh"
chmod +x "$WORKSPACE_DIR/scripts/git-auto-sync.sh"
pgrep -f "git-auto-sync.sh" >/dev/null || "$WORKSPACE_DIR/scripts/git-auto-sync.sh" --daemon

# ai-chief-of-staff の取り込み
AICOS_REPO_URL="${AICOS_REPO_URL:-https://github.com/tomochang/ai-chief-of-staff.git}"
AICOS_DIR="$WORKSPACE_DIR/tools/ai-chief-of-staff"
mkdir -p "$WORKSPACE_DIR/tools" "$WORKSPACE_DIR/skills/schedule-reply" "$WORKSPACE_DIR/hooks" "$WORKSPACE_DIR/scripts"
if [ -d "$AICOS_DIR/.git" ]; then
  git -C "$AICOS_DIR" pull --ff-only || true
else
  git clone --depth 1 "$AICOS_REPO_URL" "$AICOS_DIR"
fi
mkdir -p ~/.claude/commands
test -f ~/.claude/commands/today.md || cp "$AICOS_DIR/commands/today.md" ~/.claude/commands/today.md
test -f ~/.claude/commands/slack.md || cp "$AICOS_DIR/commands/slack.md" ~/.claude/commands/slack.md
test -f ~/.claude/commands/chatwork.md || cp "$AICOS_DIR/commands/chatwork.md" ~/.claude/commands/chatwork.md
test -f ~/.claude/commands/mail.md || cp "$AICOS_DIR/commands/mail.md" ~/.claude/commands/mail.md
test -f "$WORKSPACE_DIR/skills/schedule-reply/SKILL.md" || cp "$AICOS_DIR/skills/schedule-reply/SKILL.md" "$WORKSPACE_DIR/skills/schedule-reply/SKILL.md"
test -f "$WORKSPACE_DIR/hooks/post-action-check.sh" || cp "$AICOS_DIR/hooks/post-action-check.sh" "$WORKSPACE_DIR/hooks/post-action-check.sh"
test -f "$WORKSPACE_DIR/scripts/calendar-suggest.js" || cp "$AICOS_DIR/scripts/calendar-suggest.js" "$WORKSPACE_DIR/scripts/calendar-suggest.js"

# commit & push
cd "$WORKSPACE_DIR" && git add -A && git commit -m "workspace setup" && git push
```

### Windows

```powershell
# 変数
$PRIVATE_REPO_NAME = "{GITHUB_USERNAME}-workspace"
$PRIVATE_REPO_FULL = "{GITHUB_USERNAME}/$PRIVATE_REPO_NAME"
$CLAWD_DIR = if ($env:WORKSPACE_DIR) { $env:WORKSPACE_DIR } else { "$env:USERPROFILE\clawd" }
$setupRepoSlug = if ($env:SETUP_REPO_SLUG) { $env:SETUP_REPO_SLUG } else { "tomochang/upsider-claude-setup" }
$setupRepoRef  = if ($env:SETUP_REPO_REF) { $env:SETUP_REPO_REF } else { "main" }
$REPO_RAW = "https://raw.githubusercontent.com/$setupRepoSlug/$setupRepoRef"
$AICOS_REPO_URL = if ($env:AICOS_REPO_URL) { $env:AICOS_REPO_URL } else { "https://github.com/tomochang/ai-chief-of-staff.git" }

# ワークスペース作成
New-Item -ItemType Directory -Force -Path "$CLAWD_DIR\output", "$CLAWD_DIR\private", "$CLAWD_DIR\scripts" | Out-Null

cd $CLAWD_DIR
$isGit = git rev-parse --is-inside-work-tree 2>$null
if (-not $isGit) { git init }

# 個人privateリポジトリ作成（未作成時のみ）
$repoExists = gh repo view $PRIVATE_REPO_FULL 2>$null
if (-not $repoExists) {
    gh repo create $PRIVATE_REPO_FULL --private --description "Personal workspace auto-synced from Claude Code"
}

# origin を個人privateへ接続
git remote remove origin 2>$null
git remote add origin "https://github.com/$PRIVATE_REPO_FULL.git"

# 初回push
git checkout -B main
git add -A; git commit -m "initial workspace" --allow-empty
git push -u origin main

# グローバル CLAUDE.md
if (-not (Test-Path "$env:USERPROFILE\CLAUDE.md")) {
    Invoke-WebRequest -Uri "$REPO_RAW/GLOBAL_CLAUDE_MD.md" -OutFile "$env:USERPROFILE\CLAUDE.md"
}
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude" | Out-Null
if (-not (Test-Path "$env:USERPROFILE\.claude\CLAUDE.md")) {
    Invoke-WebRequest -Uri "$REPO_RAW/GLOBAL_CLAUDE_MD.md" -OutFile "$env:USERPROFILE\.claude\CLAUDE.md"
}

# Dynamic Product Architect メソドロジー
if (-not (Test-Path "$CLAWD_DIR\output\dynamic-product-architect-v5.2-ja.md")) {
    Invoke-WebRequest -Uri "$REPO_RAW/dynamic-product-architect-v5.2-ja.md" -OutFile "$CLAWD_DIR\output\dynamic-product-architect-v5.2-ja.md"
}

# 非エンジニア向けガードレール（重複防止）
$agentsMd = "$CLAWD_DIR\AGENTS.md"
$guardrailMarker = "## Non-Engineer Guardrails"
if (-not (Test-Path $agentsMd) -or -not (Select-String -Path $agentsMd -Pattern $guardrailMarker -Quiet)) {
    @"

## Non-Engineer Guardrails

- 破壊的操作（``rm -rf``, ``git reset --hard``, 履歴改変）はユーザーの明示許可なしで実行しない
- 外部送信（メール/Slack投稿/本番デプロイ/公開URL共有）は実行前に必ず確認する
- ``credentials*.json``, ``.env``, token, secret をGitにcommitしない
- 高リスク変更（DBマイグレーション、権限設定変更、課金リソース作成）は実行前に理由と影響を提示する
- 不明点がある場合は推測で実行せず、選択肢と推奨案を提示して確認する
"@ | Add-Content $agentsMd
}

# ai-chief-of-staff の取り込み
$AicosDir = "$CLAWD_DIR\tools\ai-chief-of-staff"
New-Item -ItemType Directory -Force -Path "$CLAWD_DIR\tools", "$CLAWD_DIR\skills\schedule-reply", "$CLAWD_DIR\hooks", "$CLAWD_DIR\scripts", "$env:USERPROFILE\.claude\commands" | Out-Null
if (Test-Path "$AicosDir\.git") {
    git -C $AicosDir pull --ff-only
} else {
    git clone --depth 1 $AICOS_REPO_URL $AicosDir
}
if (-not (Test-Path "$env:USERPROFILE\.claude\commands\today.md"))    { Copy-Item "$AicosDir\commands\today.md" "$env:USERPROFILE\.claude\commands\today.md" }
if (-not (Test-Path "$env:USERPROFILE\.claude\commands\slack.md"))    { Copy-Item "$AicosDir\commands\slack.md" "$env:USERPROFILE\.claude\commands\slack.md" }
if (-not (Test-Path "$env:USERPROFILE\.claude\commands\chatwork.md")) { Copy-Item "$AicosDir\commands\chatwork.md" "$env:USERPROFILE\.claude\commands\chatwork.md" }
if (-not (Test-Path "$env:USERPROFILE\.claude\commands\mail.md"))     { Copy-Item "$AicosDir\commands\mail.md" "$env:USERPROFILE\.claude\commands\mail.md" }
if (-not (Test-Path "$CLAWD_DIR\skills\schedule-reply\SKILL.md"))     { Copy-Item "$AicosDir\skills\schedule-reply\SKILL.md" "$CLAWD_DIR\skills\schedule-reply\SKILL.md" }
if (-not (Test-Path "$CLAWD_DIR\hooks\post-action-check.sh"))         { Copy-Item "$AicosDir\hooks\post-action-check.sh" "$CLAWD_DIR\hooks\post-action-check.sh" }
if (-not (Test-Path "$CLAWD_DIR\scripts\calendar-suggest.js"))        { Copy-Item "$AicosDir\scripts\calendar-suggest.js" "$CLAWD_DIR\scripts\calendar-suggest.js" }

# commit & push
cd $CLAWD_DIR; git add -A; git commit -m "workspace setup"; git push
```

---

## Phase 8: カスタムコマンド

Mac:
```bash
mkdir -p ~/.claude/commands
```

Windows:
```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\commands" | Out-Null
```

### /commit

```bash
test -f ~/.claude/commands/commit.md || cat > ~/.claude/commands/commit.md << 'CMDEOF'
# /commit - Git Commit & Push

変更をステージング、コミット、プッシュする。

## 手順
1. `git status` で変更確認
2. `git diff` で差分確認
3. `git log --oneline -5` でスタイル確認
4. コミットメッセージ作成 → ステージング → コミット → プッシュ

## ルール
- 機密ファイル(.env, credentials等)はコミットしない
- pushに失敗したら原因を調査
CMDEOF
```

### /pr

```bash
test -f ~/.claude/commands/pr.md || cat > ~/.claude/commands/pr.md << 'CMDEOF'
# /pr - Pull Request 作成

GitHub PRを作成する。

## 手順
1. `git log main..HEAD` → `git diff main...HEAD`
2. PRタイトル + 説明を作成
3. `git push -u origin <branch>` → `gh pr create`

## ルール
- タイトルは70文字以内
- 作成後はPR URLを報告
CMDEOF
```

### /mail

Mac:
```bash
SETUP_REPO_SLUG="${SETUP_REPO_SLUG:-tomochang/upsider-claude-setup}"
SETUP_REPO_REF="${SETUP_REPO_REF:-main}"
REPO_RAW="https://raw.githubusercontent.com/${SETUP_REPO_SLUG}/${SETUP_REPO_REF}"
test -f ~/.claude/commands/mail.md || curl -fsSL "${REPO_RAW}/mail-command.md" -o ~/.claude/commands/mail.md
```

Windows:
```powershell
$setupRepoSlug = if ($env:SETUP_REPO_SLUG) { $env:SETUP_REPO_SLUG } else { "tomochang/upsider-claude-setup" }
$setupRepoRef  = if ($env:SETUP_REPO_REF)  { $env:SETUP_REPO_REF }  else { "main" }
$REPO_RAW = "https://raw.githubusercontent.com/$setupRepoSlug/$setupRepoRef"
$dst = "$env:USERPROFILE\.claude\commands\mail.md"
if (-not (Test-Path $dst)) { Invoke-WebRequest -Uri "$REPO_RAW/mail-command.md" -OutFile $dst }
```

→ mail.md 内のプレースホルダ（署名、カレンダーID）をユーザーに確認して置換:
```
mail.md をカスタマイズします:
- GoogleカレンダーID（通常はメールアドレスと同じ。例: taro@example.com）
- スキップしたいメール送信元があれば教えてください
```

### private ディレクトリ

Mac:
```bash
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/clawd}"
if [ -d "$WORKSPACE_DIR" ]; then
  mkdir -p "$WORKSPACE_DIR/private"

  test -f "$WORKSPACE_DIR/private/{USER_NAME_LOWER}_relationships.md" || cat > "$WORKSPACE_DIR/private/{USER_NAME_LOWER}_relationships.md" << 'EOF'
# 人間関係メモ
## 社内
<!-- 名前・役職・やり取りメモを追記 -->
## 社外
<!-- 名前・会社・関係性・やり取りメモを追記 -->
EOF

  test -f "$WORKSPACE_DIR/private/{USER_NAME_LOWER}_todo.md" || cat > "$WORKSPACE_DIR/private/{USER_NAME_LOWER}_todo.md" << 'EOF'
# TODO リスト
## 直近の予定
| 日付 | 時間 | 内容 | 備考 |
|------|------|------|------|
## タスク
### 進行中
### 保留
### 完了
EOF
fi
```

Windows:
```powershell
$clawdDir = "$env:USERPROFILE\clawd"
if (Test-Path $clawdDir) {
    New-Item -ItemType Directory -Force -Path "$clawdDir\private" | Out-Null

    $relFile = "$clawdDir\private\{USER_NAME_LOWER}_relationships.md"
    if (-not (Test-Path $relFile)) {
        @"
# 人間関係メモ
## 社内
<!-- 名前・役職・やり取りメモを追記 -->
## 社外
<!-- 名前・会社・関係性・やり取りメモを追記 -->
"@ | Set-Content $relFile -Encoding UTF8
    }

    $todoFile = "$clawdDir\private\{USER_NAME_LOWER}_todo.md"
    if (-not (Test-Path $todoFile)) {
        @"
# TODO リスト
## 直近の予定
| 日付 | 時間 | 内容 | 備考 |
|------|------|------|------|
## タスク
### 進行中
### 保留
### 完了
"@ | Set-Content $todoFile -Encoding UTF8
    }
}
```

---

## Phase 9: 追加 CLI ツール

### Mac

```bash
# 一括インストール
BREW_PKGS=""
command -v gog  || BREW_PKGS="$BREW_PKGS gogcli"
command -v tmux || BREW_PKGS="$BREW_PKGS tmux"
command -v go   || BREW_PKGS="$BREW_PKGS go"
[ -n "$BREW_PKGS" ] && brew install $BREW_PKGS

# Ghostty + フォント
test -d /Applications/Ghostty.app || brew install --cask ghostty
brew list font-jetbrains-mono &>/dev/null 2>&1 || brew install --cask font-jetbrains-mono
```

### Windows

```powershell
# gogcli（GitHub Releases からバイナリ直接インストール）
if (-not (Get-Command gog -ErrorAction SilentlyContinue)) {
    $gogVersion = "0.11.0"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
    $gogZip = "$env:TEMP\gogcli.zip"
    $gogDir = "$env:LOCALAPPDATA\Programs\gogcli"
    Invoke-WebRequest -Uri "https://github.com/steipete/gogcli/releases/download/v${gogVersion}/gogcli_${gogVersion}_windows_${arch}.zip" -OutFile $gogZip
    New-Item -ItemType Directory -Force -Path $gogDir | Out-Null
    Expand-Archive -Path $gogZip -DestinationPath $gogDir -Force
    Remove-Item $gogZip
    # PATH に追加
    $env:PATH = "$gogDir;$env:PATH"
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$gogDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$gogDir;$userPath", "User")
    }
}

# Go（gogcli以外で必要な場合のみ）
if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    winget install GoLang.Go --accept-source-agreements --accept-package-agreements
    $env:PATH = "$env:USERPROFILE\go\bin;C:\Program Files\Go\bin;$env:PATH"
}

# Windows Terminal + JetBrains Mono フォント（Ghostty/tmux の代替）
# Windows Terminal は標準搭載。フォントのみ追加。
winget list "JetBrains Mono" 2>$null
if ($LASTEXITCODE -ne 0) {
    winget install "JetBrainsMono.NerdFont" --accept-source-agreements --accept-package-agreements 2>$null
}
```

### gogcli GCP 認証

Mac:
```bash
GOG_DIR="$HOME/Library/Application Support/gogcli"
```

Windows:
```powershell
$GOG_DIR = "$env:APPDATA\gogcli"
```

**credentials.json がなければスキップして先に進む。** セットアップ完了後に案内する。

Mac:
```bash
mkdir -p "$GOG_DIR"
if [ ! -f "$GOG_DIR/credentials.json" ]; then
  echo "⏭️ credentials.json 未配置 → gogcli認証はスキップ（後で設定可能）"
else
  gog auth add {USER_EMAIL}
fi
```

Windows:
```powershell
New-Item -ItemType Directory -Force -Path $GOG_DIR | Out-Null
if (-not (Test-Path "$GOG_DIR\credentials.json")) {
    Write-Host "⏭️ credentials.json 未配置 → gogcli認証はスキップ（後で設定可能）" -ForegroundColor Yellow
} else {
    gog auth add {USER_EMAIL}
}
```

→ ユーザーに案内:
```
ブラウザが開きます。Googleアカウントでログインしてください。
「Googleで確認されていません」→「詳細」→「安全でないページに移動」で正常です。
```

### npm ツール

```bash
command -v vercel || npm install -g vercel
command -v takt   || npm install -g takt
```

### Playwright（Mac のみ）

```bash
npx playwright --version &>/dev/null || { npm install -g playwright && npx playwright install chromium; }
```

### Vercel ログイン

```bash
vercel whoami 2>/dev/null || vercel login
```

---

## Phase 10: シェル・ターミナル設定

### Ghostty（Mac のみ）

```bash
mkdir -p ~/.config/ghostty
test -f ~/.config/ghostty/config || cat > ~/.config/ghostty/config << 'EOF'
font-family = "JetBrains Mono"
font-size = 14
theme = "Catppuccin Mocha"
macos-option-as-alt = true
window-decoration = true
cursor-style = block
cursor-style-blink = false
scrollback-limit = 10000
EOF
```

### tmux

```bash
test -f ~/.tmux.conf || cat > ~/.tmux.conf << 'EOF'
unbind C-b
set -g prefix C-a
bind C-a send-prefix
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
set -sg escape-time 0
set -g history-limit 50000
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g mouse on
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
bind c new-window -c "#{pane_current_path}"
bind r source-file ~/.tmux.conf \; display "Config reloaded!"
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
set -g status-position top
set -g status-interval 1
set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
set -g status-left-length 40
set -g status-left "#[fg=#89b4fa,bold] #S #[default]"
set -g status-right-length 60
set -g status-right "#[fg=#a6adc8]%Y-%m-%d %H:%M "
set -g status-justify left
setw -g window-status-current-format "#[fg=#89b4fa,bold] #I:#W "
setw -g window-status-format "#[fg=#6c7086] #I:#W "
set -g pane-active-border-style "fg=#89b4fa"
set -g pane-border-style "fg=#313244"
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @resurrect-capture-pane-contents 'on'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'
run '~/.tmux/plugins/tpm/tpm'
EOF

test -d ~/.tmux/plugins/tpm || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### .zshrc（Mac のみ・追記のみ）

```bash
grep -q 'NVM_DIR' ~/.zshrc 2>/dev/null || cat >> ~/.zshrc << 'ZSHRC'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
ZSHRC

grep -q 'BUN_INSTALL' ~/.zshrc 2>/dev/null || cat >> ~/.zshrc << 'ZSHRC'

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
ZSHRC

grep -q '/usr/local/go/bin' ~/.zshrc 2>/dev/null || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
grep -q '.local/bin' ~/.zshrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

source ~/.zshrc
```

### PowerShell Profile（Windows のみ・追記のみ）

```powershell
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Force -Path $profilePath | Out-Null }

# NVM パス
if (-not (Select-String -Path $profilePath -Pattern "NVM_HOME" -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content $profilePath "`n# NVM`n`$env:NVM_HOME = `"`$env:APPDATA\nvm`"`n`$env:PATH = `"`$env:NVM_HOME;`$env:PATH`""
}

# Go パス
if (-not (Select-String -Path $profilePath -Pattern "Go\\bin" -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content $profilePath "`n# Go`n`$env:PATH = `"C:\Program Files\Go\bin;`$env:USERPROFILE\go\bin;`$env:PATH`""
}

# Bun パス
if (-not (Select-String -Path $profilePath -Pattern "\.bun" -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content $profilePath "`n# Bun`n`$env:BUN_INSTALL = `"`$env:USERPROFILE\.bun`"`n`$env:PATH = `"`$env:BUN_INSTALL\bin;`$env:PATH`""
}
```

---

## Phase 11: スモークテスト + 完了報告

### Mac

```bash
echo ""
echo "=========================================="
echo " スモークテスト"
echo "=========================================="
echo "--- Foundation ---"
brew --version 2>/dev/null | head -1
git --version
gh auth status 2>&1 | head -2
echo "--- Node.js ---"
node --version
bun --version 2>/dev/null || echo "bun: N/A"
echo "--- Claude Code ---"
claude --version
echo "--- CLI Tools ---"
gog --version 2>/dev/null | head -1 || echo "gog: 要credentials"
tmux -V 2>/dev/null || echo "tmux: N/A"
vercel --version 2>/dev/null | head -1 || echo "vercel: 未設定"
echo "--- Terminal ---"
test -d /Applications/Ghostty.app && echo "Ghostty: OK" || echo "Ghostty: N/A"
echo "--- Project ---"
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/clawd}"
test -d "$WORKSPACE_DIR/.git" && echo "workspace: OK" || echo "workspace: 未初期化"
echo "=========================================="
```

### Windows

```powershell
Write-Host ""
Write-Host "=========================================="
Write-Host " スモークテスト"
Write-Host "=========================================="
Write-Host "--- Foundation ---"
git --version
gh auth status 2>&1 | Select-Object -First 2
Write-Host "--- Node.js ---"
node --version
bun --version 2>$null; if ($LASTEXITCODE -ne 0) { Write-Host "bun: N/A" }
Write-Host "--- Claude Code ---"
claude --version
Write-Host "--- CLI Tools ---"
try { gog --version 2>$null | Select-Object -First 1 } catch { Write-Host "gog: 要credentials" }
try { vercel --version 2>$null | Select-Object -First 1 } catch { Write-Host "vercel: 未設定" }
Write-Host "--- Project ---"
if (Test-Path "$env:USERPROFILE\clawd\.git") { Write-Host "workspace: OK" } else { Write-Host "workspace: 未初期化" }
Write-Host "=========================================="
```

### MCP 接続確認（共通）

スモークテスト後、以下をユーザーに案内して MCP が動作するか確認する:

```
最後に動作確認をします。以下を試してみてください:

1. 新しいターミナルで Claude Code を起動:
   cd ${WORKSPACE_DIR:-~/clawd} && claude   (Mac)
   cd ${WORKSPACE_DIR:-~\clawd}; claude     (Windows)

2. Claude に聞いてみる:
   「#general の最新メッセージを1件見せて」

→ Slack のメッセージが表示されれば成功です！
→ エラーが出たら Slack トークン（xoxp-）を確認してください。
```

完了報告（Mac）:

```
✅ セットアップ完了！

■ 次のステップ:
1. Ghostty を起動: Command+Space →「Ghostty」
2. tmux を起動: tmux new -s main
3. Claude Code: cd ${WORKSPACE_DIR:-~/clawd} && claude
4. 試しに:「今日のSlackの未読を教えて」

■ tmux プラグイン（初回のみ）:
   tmux内で Ctrl+A → 大文字 I

お疲れ様でした！
```

完了報告（Windows）:

```
✅ セットアップ完了！

■ 次のステップ:
1. Windows Terminal を起動
2. Claude Code: cd ${WORKSPACE_DIR:-~\clawd}; claude
3. 試しに:「今日のSlackの未読を教えて」

お疲れ様でした！
```

---

## トラブルシューティング

| 問題 | 自動回復 |
|------|---------|
| `brew: command not found` | `eval "$(/opt/homebrew/bin/brew shellenv)"` |
| `nvm: command not found` | `export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh"` |
| `gh auth login` ブラウザ開かない | 表示URLを手動でブラウザにコピーするよう案内 |
| `repository not found` | 管理者にGitHub招待依頼を案内。Phase 7 スキップ可 |
| `Marketplace not found` | `claude --version` 実行後リトライ |
| `Please login` / 認証エラー | `claude login` を実行してブラウザ認証 |
| `npm install` 失敗 | `nvm use $NODE_VERSION` → リトライ |
| Slack `invalid_auth` | xoxp- トークン全体をコピーし直すよう案内 |
| Slack Bot Token 使用 | User Token Scopes に変更 → 再Install to Workspace |
| `gog auth` エラー | 配布されたOAuth JSONを `credentials.json` にリネーム済みか確認 |
| 「Google確認されていません」 | 「詳細」→「安全でないページに移動」と案内 |
| `.zshrc` 変更反映されない | `source ~/.zshrc` |
| `sed: invalid command` | macOS: `sed -i ''`、Linux: `sed -i` |
| winget 見つからない | Microsoft Store から「App Installer」を更新 |
