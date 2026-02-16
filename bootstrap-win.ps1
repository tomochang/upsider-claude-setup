# =============================================================================
# UPSIDER Claude Code セットアップ ブートストラップ（Windows）
#
# Usage: irm https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main/bootstrap-win.ps1 | iex
#
# やること: Claude CLI (native) のインストール + セットアップ手順の配置
# やらないこと: Git, Node.js等 → Claude が全部やる
# =============================================================================
$ErrorActionPreference = "Stop"
$REPO_RAW = "https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main"

Write-Host ""
Write-Host "=========================================="
Write-Host " UPSIDER Claude Code セットアップ"
Write-Host "=========================================="
Write-Host ""
Write-Host "注意: PowerShellを管理者として実行してください" -ForegroundColor Yellow
Write-Host "=========================================="
Write-Host ""

# --- Claude CLI (native) ---
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude CLI をインストール中..."
    irm https://claude.ai/install.ps1 | iex
    Write-Host ""
}
Write-Host "Claude CLI: OK" -ForegroundColor Green

# --- セットアップワークスペース ---
$setupDir = "$env:USERPROFILE\upsider-setup"
New-Item -ItemType Directory -Force -Path $setupDir | Out-Null

Write-Host "セットアップ手順をダウンロード中..."
try {
    Invoke-WebRequest -Uri "$REPO_RAW/SETUP_AGENT.md" -OutFile "$setupDir\CLAUDE.md"
    Write-Host "準備完了" -ForegroundColor Green
} catch {
    Write-Host "ダウンロード失敗。手動で配置してください:" -ForegroundColor Red
    Write-Host "  $REPO_RAW/SETUP_AGENT.md → ~\upsider-setup\CLAUDE.md"
    exit 1
}

Write-Host ""
Write-Host "=========================================="
Write-Host " あと2ステップで完了！" -ForegroundColor Green
Write-Host "=========================================="
Write-Host ""
Write-Host " 1. 実行:" -ForegroundColor Cyan
Write-Host "    cd ~\upsider-setup; claude"
Write-Host ""
Write-Host " 2. Claude に伝える:" -ForegroundColor Cyan
Write-Host "    セットアップを開始して"
Write-Host ""
Write-Host " あとは Claude が全部やります。"
Write-Host "=========================================="
Write-Host ""
