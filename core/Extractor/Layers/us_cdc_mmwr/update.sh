#!/bin/bash
# us_cdc_mmwr 資料更新腳本
# 職責：Qdrant 寫入 + REVIEW_NEEDED 檢查
# 用法：update.sh [md_files...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/chatgpt.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="us_cdc_mmwr"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in surveillance_summary outbreak_report scientific_report case_series vital_statistics; do
    mkdir -p "$DOCS_DIR/$category"
done

# === 收集要處理的 MD 檔案 ===
MD_FILES=()
if [[ $# -gt 0 ]]; then
    MD_FILES=("$@")
else
    while IFS= read -r -d '' file; do
        MD_FILES+=("$file")
    done < <(find "$DOCS_DIR" -name "*.md" ! -name "index.md" -type f -print0 2>/dev/null)
fi

echo "📄 [$LAYER_NAME] 找到 ${#MD_FILES[@]} 個 MD 檔案"

# === Qdrant 寫入 ===
if [[ ${#MD_FILES[@]} -gt 0 ]]; then
    if chatgpt_init_env 2>/dev/null && qdrant_init_env 2>/dev/null; then
        echo "📤 [$LAYER_NAME] 寫入 Qdrant..."
        qdrant_success=0
        qdrant_failed=0
        for md_file in "${MD_FILES[@]}"; do
            if qdrant_upsert_from_md "$md_file" "$LAYER_NAME" 2>/dev/null; then
                ((qdrant_success++)) || true
            else
                ((qdrant_failed++)) || true
            fi
        done
        echo "✅ [$LAYER_NAME] Qdrant: $qdrant_success 成功, $qdrant_failed 失敗"
    else
        echo "⚠️  [$LAYER_NAME] Qdrant 連線失敗，跳過寫入"
    fi
fi

# === REVIEW_NEEDED 檢查 ===
REVIEW_FILES=()
if [[ ${#MD_FILES[@]} -gt 0 ]]; then
    for md_file in "${MD_FILES[@]}"; do
        if grep -q "\[REVIEW_NEEDED\]" "$md_file" 2>/dev/null; then
            REVIEW_FILES+=("$md_file")
        fi
    done
fi

if [[ ${#REVIEW_FILES[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  [$LAYER_NAME] 需要審核的檔案 (${#REVIEW_FILES[@]} 個):"
    for f in "${REVIEW_FILES[@]}"; do
        echo "  - $f"
    done
fi

echo ""
echo "✅ [$LAYER_NAME] Update 完成"
