# UPSIDER Claude Code セットアップ

Claude Code + Ghostty + tmux の開発環境を自動セットアップ。

## クイックスタート

### Mac

```bash
curl -fsSL https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main/bootstrap-mac.sh | bash
```

### Windows (PowerShell を管理者で実行)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
irm https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main/bootstrap-win.ps1 | iex
```

### 起動

Mac:
```bash
cd ~/upsider-setup && claude
```

Windows (PowerShell):
```powershell
cd ~\upsider-setup; claude
```

Claude が起動したら `セットアップを開始して` と入力。あとは Claude が全部やります。

### セキュリティ

このリポジトリは public です。`curl | bash` に不安がある場合は、先にスクリプトを確認できます:

```bash
# Mac: ダウンロードしてから中身を確認 → 実行
curl -fsSL https://raw.githubusercontent.com/tomochang/upsider-claude-setup/main/bootstrap-mac.sh -o /tmp/bootstrap.sh
cat /tmp/bootstrap.sh   # 中身を確認
bash /tmp/bootstrap.sh
```

固定バージョンで実行したい場合（推奨）:

```bash
# main ではなくコミットSHAを固定して取得する
PINNED_SHA="<commit-sha>"
curl -fsSL "https://raw.githubusercontent.com/tomochang/upsider-claude-setup/${PINNED_SHA}/bootstrap-mac.sh" -o /tmp/bootstrap.sh
bash /tmp/bootstrap.sh
```

## ファイル構成

| ファイル | 役割 |
|---------|------|
| `bootstrap-mac.sh` | Mac用ブートストラップ（Claude CLI + ワークスペース作成） |
| `bootstrap-win.ps1` | Windows用ブートストラップ（Claude CLI + ワークスペース作成） |
| `SETUP_AGENT.md` | Claude が読んで自動実行するセットアップ手順（= CLAUDE.md） |
| `GLOBAL_CLAUDE_MD.md` | グローバル `~/.claude/CLAUDE.md` テンプレート |
| `dynamic-product-architect-v5.2-ja.md` | UPSIDER Dynamic Product Architect メソドロジー |
| `slack-app-manifest.yaml` | Slack App 作成用 Manifest |
| `versions.env` | ツールバージョン定義 |

## 配布前の準備

### OAuth運用方針（固定）

- Google OAuth クライアントは **ユーザーごとに作らない**
- 以下の **共通1クライアント** を使う:
  - `UPSIDER-Claude-Setup-Prod`

### 配布ファイル

Slack の `#private_ai_pdm` 固定投稿に以下を置く:

- `UPSIDER-Claude-Setup-Prod.json`（Prodクライアント）

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
