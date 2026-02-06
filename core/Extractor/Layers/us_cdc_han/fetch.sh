#!/bin/bash
# us_cdc_han 資料擷取腳本
# 功能：下載 CDC Health Alert Network RSS feed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

LAYER_NAME="us_cdc_han"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

# RSS Feed URL (CDC HAN managed feed)
RSS_URL="https://tools.cdc.gov/api/v2/resources/media/413690.rss"

mkdir -p "$RAW_DIR"

echo "📥 [$LAYER_NAME] 開始擷取 CDC HAN RSS..."

# 下載 RSS XML
XML_FILE="$RAW_DIR/rss-$(date +%Y%m%d-%H%M%S).xml"
if ! rss_fetch "$RSS_URL" "$XML_FILE"; then
    echo "❌ [$LAYER_NAME] RSS 下載失敗" >&2
    exit 1
fi

# 驗證 RSS
if ! rss_validate "$XML_FILE"; then
    echo "❌ [$LAYER_NAME] RSS 格式無效" >&2
    exit 1
fi

# 計算 item 數量
ITEM_COUNT=$(rss_count_items "$XML_FILE")
echo "📊 [$LAYER_NAME] RSS 包含 $ITEM_COUNT 筆資料"

# 轉換為 JSONL
JSONL_FILE="$RAW_DIR/rss-$(date +%Y%m%d-%H%M%S).jsonl"
if ! rss_extract_items_jsonl "$XML_FILE" > "$JSONL_FILE"; then
    echo "❌ [$LAYER_NAME] JSONL 轉換失敗" >&2
    exit 1
fi

# 驗證 JSONL 行數
JSONL_COUNT=$(wc -l < "$JSONL_FILE" | tr -d ' ')
echo "📊 [$LAYER_NAME] JSONL 包含 $JSONL_COUNT 筆資料"

# 記錄最後擷取時間
echo "$(date -Iseconds)" > "$RAW_DIR/.last_fetch"

echo "✅ [$LAYER_NAME] Fetch 完成: $JSONL_FILE"
