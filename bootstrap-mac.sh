#!/bin/bash
# =============================================================================
# UPSIDER Claude Code セットアップ ブートストラップ（macOS）
#
# Usage: curl -fsSL https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main/bootstrap-mac.sh | bash
#
# やること: Claude CLI (native) のインストール + セットアップ手順の配置
# やらないこと: Homebrew, Xcode, Git等 → Claude が全部やる
# =============================================================================
set -e

REPO_RAW="https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main"

echo ""
echo "=========================================="
echo " UPSIDER Claude Code セットアップ"
echo "=========================================="
echo ""
echo "⚠️  知っておくこと:"
echo "  1. パスワード入力 → 文字は表示されない（正常）"
echo "  2. パスワードを何度も聞かれる → コピペ連打推奨"
echo "=========================================="
echo ""

# --- macOS チェック ---
if [ "$(uname -s)" != "Darwin" ]; then
  echo "❌ macOS専用。Windowsは bootstrap-win.ps1 を使ってください。"
  exit 1
fi
echo "✅ macOS ($(uname -m))"

# --- Claude CLI (native) ---
if ! command -v claude &>/dev/null; then
  echo ""
  echo "📦 Claude CLI をインストール中..."
  curl -fsSL https://claude.ai/install.sh | bash
  export PATH="$HOME/.claude/bin:$PATH"
  echo ""
fi
echo "✅ Claude CLI: $(claude --version 2>/dev/null || echo 'installed')"

# --- セットアップワークスペース ---
SETUP_DIR="$HOME/upsider-setup"
mkdir -p "$SETUP_DIR"

echo "📥 セットアップ手順をダウンロード中..."
if curl -fsSL "${REPO_RAW}/SETUP_AGENT.md" -o "$SETUP_DIR/CLAUDE.md" 2>/dev/null; then
  echo "✅ 準備完了"
else
  echo "❌ ダウンロード失敗。以下を手動で配置してください:"
  echo "   ${REPO_RAW}/SETUP_AGENT.md → ~/upsider-setup/CLAUDE.md"
  exit 1
fi

echo ""
echo "=========================================="
echo " ✅ あと2ステップで完了！"
echo "=========================================="
echo ""
echo " 1. 実行:"
echo ""
echo "    cd ~/upsider-setup && claude"
echo ""
echo " 2. Claude に伝える:"
echo ""
echo "    セットアップを開始して"
echo ""
echo " あとは Claude が全部やります。"
echo "=========================================="
echo ""
