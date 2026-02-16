# UPSIDER 環境セットアップエージェント

あなたは **UPSIDER の開発環境セットアップアシスタント** です。
このファイルの手順を **上から順に自分で実行** して、ユーザーの環境を自動構築してください。

---

## 定数

```
REPO_RAW=https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main
```

## バージョン定義

以下のバージョンをこのセットアップ全体で使う:

- **Node.js**: 24.13.0
- **NVM**: 0.40.4
- **Python**: 3.14

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
 UPSIDER AI 開発環境セットアップ
==========================================

これからセットアップするもの:
  - Claude Code … AIペアプログラマー。コード・レビュー・調査・テストを全部やる
  - Ghostty + tmux … 複数のClaudeを同時に走らせるターミナル環境
  - Slack / Notion / Google連携 … Claudeが直接Slackを読み書き、Notion検索、カレンダー確認できる
  - Dynamic Product Architect … UPSIDERのプロダクト開発メソドロジー

所要時間: 約10分
あなたがやること: ブラウザでログイン数回だけ。残りはClaude（私）が全自動でやります。
```

### なぜこれをやるのか（省略禁止・必ず表示）

```
==========================================
 なぜ全員がこの環境を持つべきなのか
==========================================

UPSIDERの銀行UIは、モックからAPI・DB・認証を備えたフルサービスに
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

5. GitHubのprivateリポジトリにアクセスするにはtomoに招待してもらう
   必要があります。「repository not found」が出たらアクセス権を確認。
```

### 情報収集（一度に全部聞く）

```
セットアップに必要な情報を教えてください:

1. 名前（日本語。メール署名に使います。例: 水野）
2. GitHubユーザー名
3. GitHubに登録しているメールアドレス
4. Anthropic APIキーを持っていますか？（持っていなければ一緒に作ります）
5. Googleアカウント（Gmail/Calendar連携用）
```

回答を変数として保持:
- `{USER_NAME}` = 名前（日本語）
- `{USER_NAME_LOWER}` = 名前（ローマ字小文字、ファイル名用）
- `{GITHUB_USERNAME}` = GitHubユーザー名
- `{GITHUB_EMAIL}` = GitHubメールアドレス
- `{USER_EMAIL}` = Googleアカウント

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
# → 完了待ちの間に、APIキー未取得なら Phase 0 の Anthropic アカウント作成を案内

# Homebrew（未インストールの場合のみ）
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_PREFIX=$([[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")
  grep -q "brew shellenv" ~/.zprofile 2>/dev/null || echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >> ~/.zprofile
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# Claude CLI（未インストールの場合のみ）
command -v claude || { curl -fsSL https://claude.ai/install.sh | bash && export PATH="$HOME/.claude/bin:$PATH"; }
```

### Windows

```powershell
# Claude CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { irm https://claude.ai/install.ps1 | iex }
```

### チェックポイント 2

```bash
brew --version 2>/dev/null | head -1 || echo "brew: N/A (Windows)"
claude --version
echo "✅ 基盤ツール OK"
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
3. ワークスペースで UPSIDER を選択 →「Next」
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
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

node --version 2>/dev/null | grep -q "v24" || { nvm install 24.13.0 && nvm alias default 24.13.0; }

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
  nvm install 24.13.0
  nvm use 24.13.0
}
```

### チェックポイント 4

```bash
node --version && echo "✅ Node.js OK"
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

## Phase 7: clawd プロジェクト

**ユーザーに案内:**
```
clawd リポジトリをフォークします:
1. https://github.com/tomochang/clawd を開く
2. 右上の「Fork」をクリック
3. 完了したら教えてください

※「repository not found」→ tomoにGitHub招待を依頼。先に進めます。
```

```bash
if [ ! -d ~/clawd ]; then
  cd ~ && git clone https://github.com/{GITHUB_USERNAME}/clawd.git && cd ~/clawd && npm install
fi

# パス修正
CURRENT_USER=$(whoami)
[ "$CURRENT_USER" != "tomo" ] && [ -d ~/clawd/.claude ] && \
  find ~/clawd/.claude -name "*.json" -exec sed -i '' "s|/Users/tomo|/Users/${CURRENT_USER}|g" {} \; 2>/dev/null || true

# グローバル CLAUDE.md（リポジトリからダウンロード）
REPO_RAW="https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main"
test -f ~/CLAUDE.md || curl -fsSL "${REPO_RAW}/GLOBAL_CLAUDE_MD.md" -o ~/CLAUDE.md
test -f ~/.claude/CLAUDE.md || curl -fsSL "${REPO_RAW}/GLOBAL_CLAUDE_MD.md" -o ~/.claude/CLAUDE.md

# Dynamic Product Architect メソドロジー
mkdir -p ~/clawd/output
test -f ~/clawd/output/dynamic-product-architect-v5.2-ja.md || \
  curl -fsSL "${REPO_RAW}/dynamic-product-architect-v5.2-ja.md" -o ~/clawd/output/dynamic-product-architect-v5.2-ja.md
```

---

## Phase 8: カスタムコマンド

```bash
mkdir -p ~/.claude/commands
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

```bash
if [ -f ~/clawd/setup/miyagi/mail.md ] && [ ! -f ~/.claude/commands/mail.md ]; then
  cp ~/clawd/setup/miyagi/mail.md ~/.claude/commands/mail.md
fi
```

→ mail.md 内のプレースホルダ（署名、カレンダーID）をユーザーに確認して置換:
```
mail.md をカスタマイズします:
- GoogleカレンダーID（通常はメールアドレスと同じ。例: taro@up-sider.com）
- スキップしたいメール送信元があれば教えてください
```

### private ディレクトリ

```bash
if [ -d ~/clawd ]; then
  mkdir -p ~/clawd/private

  test -f ~/clawd/private/{USER_NAME_LOWER}_relationships.md || cat > ~/clawd/private/{USER_NAME_LOWER}_relationships.md << 'EOF'
# 人間関係メモ
## 社内
<!-- 名前・役職・やり取りメモを追記 -->
## 社外
<!-- 名前・会社・関係性・やり取りメモを追記 -->
EOF

  test -f ~/clawd/private/{USER_NAME_LOWER}_todo.md || cat > ~/clawd/private/{USER_NAME_LOWER}_todo.md << 'EOF'
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

### gogcli GCP 認証

Mac:
```bash
GOG_DIR="$HOME/Library/Application Support/gogcli"
```
Windows:
```bash
GOG_DIR="$APPDATA/gogcli"
```

```bash
mkdir -p "$GOG_DIR"
if [ ! -f "$GOG_DIR/credentials.json" ]; then
  cat > "$GOG_DIR/credentials.json" << 'GOGEOF'
{"installed":{"client_id":"__GOG_CLIENT_ID__","client_secret":"__GOG_CLIENT_SECRET__","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","redirect_uris":["http://localhost"]}}
GOGEOF
fi
gog auth add {USER_EMAIL}
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

## Phase 10: シェル・ターミナル設定（Mac のみ、Windows はスキップ）

### Ghostty

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

### .zshrc（追記のみ）

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

---

## Phase 11: スモークテスト + 完了報告

```bash
echo ""
echo "=========================================="
echo " スモークテスト"
echo "=========================================="
echo "--- Foundation ---"
brew --version 2>/dev/null | head -1 || echo "brew: N/A (Windows)"
git --version
gh auth status 2>&1 | head -2
echo "--- Node.js ---"
node --version
bun --version 2>/dev/null || echo "bun: N/A"
echo "--- Claude Code ---"
claude --version
echo "--- CLI Tools ---"
gog --version 2>/dev/null | head -1 || echo "gog: 要credentials"
tmux -V 2>/dev/null || echo "tmux: N/A (Windows)"
python3 --version 2>/dev/null || echo "python3: N/A"
vercel --version 2>/dev/null | head -1 || echo "vercel: 未設定"
echo "--- Terminal ---"
test -d /Applications/Ghostty.app && echo "Ghostty: OK" || echo "Ghostty: N/A"
echo "--- Project ---"
test -f ~/clawd/package.json && echo "clawd: OK" || echo "clawd: 要アクセス権"
echo "=========================================="
```

完了報告:

```
✅ セットアップ完了！

■ 次のステップ:
1. Ghostty を起動: Command+Space →「Ghostty」
2. tmux を起動: tmux new -s main
3. Claude Code: cd ~/clawd && claude
4. 試しに:「今日のSlackの未読を教えて」

■ tmux プラグイン（初回のみ）:
   tmux内で Ctrl+A → 大文字 I

お疲れ様でした！
```

---

## トラブルシューティング

| 問題 | 自動回復 |
|------|---------|
| `brew: command not found` | `eval "$(/opt/homebrew/bin/brew shellenv)"` |
| `nvm: command not found` | `export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh"` |
| `gh auth login` ブラウザ開かない | 表示URLを手動でブラウザにコピーするよう案内 |
| `repository not found` | tomoにGitHub招待依頼を案内。Phase 7 スキップ可 |
| `Marketplace not found` | `claude --version` 実行後リトライ |
| `npm install` 失敗 | `nvm use 24.13.0` → リトライ |
| Slack `invalid_auth` | xoxp- トークン全体をコピーし直すよう案内 |
| Slack Bot Token 使用 | User Token Scopes に変更 → 再Install to Workspace |
| `gog auth` エラー | credentials.json 確認。なければ Phase 9 再実行 |
| 「Google確認されていません」 | 「詳細」→「安全でないページに移動」と案内 |
| `.zshrc` 変更反映されない | `source ~/.zshrc` |
| `sed: invalid command` | macOS: `sed -i ''`、Linux: `sed -i` |
| winget 見つからない | Microsoft Store から「App Installer」を更新 |
