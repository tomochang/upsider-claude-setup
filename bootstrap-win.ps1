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
    return
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

    # --- PATH を自動設定 ---
    $claudeBin = Join-Path $env:USERPROFILE ".local\bin"
    if (Test-Path (Join-Path $claudeBin "claude.exe")) {
        # 現在のセッションに追加
        if ($env:PATH -notlike "*$claudeBin*") {
            $env:PATH = "$claudeBin;$env:PATH"
        }
        # 永続的な User PATH に追加
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$claudeBin*") {
            [Environment]::SetEnvironmentVariable("Path", "$claudeBin;$userPath", "User")
            Write-Host "PATH に $claudeBin を追加しました。" -ForegroundColor Green
        }
    } else {
        Write-Host "claude.exe が見つかりません: $claudeBin" -ForegroundColor Red
        Write-Host "https://claude.ai/download から手動インストールしてください。"
        return
    }

    # 追加後に動作確認
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "PATH を追加しましたが claude が認識されません。" -ForegroundColor Red
        Write-Host "PowerShell を再起動してから、もう一度このスクリプトを実行してください。"
        return
    }
    Write-Host "Claude CLI: OK" -ForegroundColor Green
} else {
    Write-Host "Claude CLI: OK" -ForegroundColor Green
}

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
    return
}

Write-Host ""
Write-Host "=========================================="
Write-Host " 準備完了！" -ForegroundColor Green
Write-Host "=========================================="
Write-Host ""
Write-Host " 以下を実行してください:" -ForegroundColor Cyan
Write-Host ""
Write-Host "    cd ~\upsider-setup; claude" -ForegroundColor White
Write-Host ""
Write-Host " Claude が起動したら:" -ForegroundColor Cyan
Write-Host "    セットアップを開始して" -ForegroundColor White
Write-Host ""
Write-Host " あとは Claude が全部やります。"
Write-Host "=========================================="
Write-Host ""
Write-Host "--- トラブルシューティング ---" -ForegroundColor DarkGray
Write-Host " '管理者権限': PowerShellを右クリック →「管理者として実行」" -ForegroundColor DarkGray
Write-Host " 'claude が見つからない': PowerShellを再起動してから再実行" -ForegroundColor DarkGray
Write-Host ""
