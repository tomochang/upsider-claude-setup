# Procedural Memory System

ツール操作の成功パターンを記録・検索・再実行する手順メモリ。

## ディレクトリ構成

```
procedures/
├── INDEX.md              # 全手順の軽量インデックス（常時参照用）
├── by-domain/<domain>/   # 承認済み手順 (.proc.md)
├── staging/              # 未承認の候補手順
└── lib/                  # hook スクリプト
```

## .proc.md フォーマット

YAMLフロントマター + 自然言語Playbook。Claudeがこのファイルを読めばゼロ知識でもタスクを再現できることがゴール。

## ライフサイクル

1. **Trace**: PostToolUse hookが全ツール呼び出しをトレースファイルに記録
2. **Capture**: Stop hookがトレースを分析し、成功パターンを `staging/` に候補生成
3. **Retrieve**: UserPromptSubmit hookがINDEX.mdの trigger_patterns でマッチング → サジェスト
4. **Promote**: confidence >= 0.85 かつ success_count >= 5 で skills/ への昇格候補に

## claude-mem との違い

- claude-mem: 宣言的記憶（事実・決定・発見）
- procedures: 手続き的記憶（再実行可能なツール操作パターン）
