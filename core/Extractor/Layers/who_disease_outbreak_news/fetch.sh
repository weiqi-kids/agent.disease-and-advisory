#!/bin/bash
# who_disease_outbreak_news 資料擷取腳本
# 功能：下載 WHO Disease Outbreak News JSON API

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/api.sh"

LAYER_NAME="who_disease_outbreak_news"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

# API Endpoint
API_URL="https://www.who.int/api/news/diseaseoutbreaknews"

# 預設取最近 100 筆
PAGE_SIZE="${WHO_PAGE_SIZE:-100}"

mkdir -p "$RAW_DIR"

echo "📥 [$LAYER_NAME] 開始擷取 WHO Disease Outbreak News API..."

# 下載 JSON 並轉為 JSONL
JSONL_FILE="$RAW_DIR/api-$(date +%Y%m%d-%H%M%S).jsonl"

if ! api_fetch_odata "$API_URL" "$JSONL_FILE" "$PAGE_SIZE" 0; then
    echo "❌ [$LAYER_NAME] API 擷取失敗" >&2
    exit 1
fi

# 驗證 JSONL
if ! api_validate_jsonl "$JSONL_FILE"; then
    echo "❌ [$LAYER_NAME] JSONL 格式無效" >&2
    exit 1
fi

# 計算筆數
ITEM_COUNT=$(api_count_items "$JSONL_FILE")
echo "📊 [$LAYER_NAME] 取得 $ITEM_COUNT 筆資料"

# 預覽前 3 筆
echo ""
echo "📋 [$LAYER_NAME] 資料預覽:"
api_extract_preview "$JSONL_FILE" 3

# 記錄最後擷取時間
echo "$(date -Iseconds)" > "$RAW_DIR/.last_fetch"

echo ""
echo "✅ [$LAYER_NAME] Fetch 完成: $JSONL_FILE"
