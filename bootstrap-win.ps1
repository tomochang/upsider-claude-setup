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

# --- 管理者権限チェック ---
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host " 管理者権限が必要です" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host " PowerShellを右クリック →「管理者として実行」" -ForegroundColor Yellow
    Write-Host " してから、もう一度このコマンドを実行してください。"
    Write-Host ""
    exit 1
}

# --- ExecutionPolicy ---
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
} catch {
    Write-Host "ExecutionPolicy の設定に失敗しました: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================="
Write-Host " UPSIDER Claude Code セットアップ"
Write-Host "=========================================="
Write-Host ""

# --- Claude CLI (native) ---
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude CLI をインストール中..."
    irm https://claude.ai/install.ps1 | iex
    Write-Host ""
    Write-Host "Claude CLI のインストールが完了しました。" -ForegroundColor Green
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host " PowerShellを再起動してから、もう一度" -ForegroundColor Yellow
    Write-Host " このスクリプトを実行してください。" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Yellow
    exit 0
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
Write-Host " 1. PowerShellを一度閉じて、再度開く" -ForegroundColor Cyan
Write-Host "    (claude コマンドをPATHに反映するため)"
Write-Host ""
Write-Host " 2. 実行:" -ForegroundColor Cyan
Write-Host "    cd ~\upsider-setup; claude"
Write-Host ""
Write-Host " 3. Claude に伝える:" -ForegroundColor Cyan
Write-Host "    セットアップを開始して"
Write-Host ""
Write-Host " あとは Claude が全部やります。"
Write-Host "=========================================="
Write-Host ""
Write-Host "--- トラブルシューティング ---" -ForegroundColor DarkGray
Write-Host " 'スクリプトの実行が無効': Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force" -ForegroundColor DarkGray
Write-Host " '管理者権限': PowerShellを右クリック →「管理者として実行」" -ForegroundColor DarkGray
Write-Host " 'claude が見つからない': PowerShellを再起動してから再実行" -ForegroundColor DarkGray
Write-Host ""
