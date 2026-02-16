# UPSIDER Claude Code セットアップ

Claude Code + Ghostty + tmux の開発環境を自動セットアップ。

## クイックスタート

### Mac

```bash
curl -fsSL https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main/bootstrap-mac.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main/bootstrap-win.ps1 | iex
```

### 起動

```bash
cd ~/upsider-setup && claude
```

Claude が起動したら `セットアップを開始して` と入力。あとは Claude が全部やります。

## ファイル構成

| ファイル | 役割 |
|---------|------|
| `bootstrap-mac.sh` | Mac用ブートストラップ（Homebrew + Claude CLI + ワークスペース作成） |
| `bootstrap-win.ps1` | Windows用ブートストラップ（winget + Claude CLI + ワークスペース作成） |
| `SETUP_AGENT.md` | Claude が読んで自動実行するセットアップ手順（= CLAUDE.md） |
| `slack-app-manifest.yaml` | Slack App 作成用 Manifest |
| `versions.env` | ツールバージョン定義 |

## 配布前の準備

`SETUP_AGENT.md` 内の以下のプレースホルダを実際の値に置換:

- `__GOG_CLIENT_ID__` → GCP OAuth Client ID
- `__GOG_CLIENT_SECRET__` → GCP OAuth Client Secret

```bash
sed -i '' 's/__GOG_CLIENT_ID__/actual-id/g' SETUP_AGENT.md
sed -i '' 's/__GOG_CLIENT_SECRET__/actual-secret/g' SETUP_AGENT.md
```

## 所要時間

| 条件 | 目安 |
|------|------|
| 開発者（Xcode CLT + Homebrew 済み） | 10分 |
| 非エンジニア（ゼロから） | 15-20分（Xcode CLT待ち含む） |
