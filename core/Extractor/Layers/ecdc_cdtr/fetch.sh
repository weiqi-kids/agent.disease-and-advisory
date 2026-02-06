#!/bin/bash
# ecdc_cdtr 資料擷取腳本
# 功能：下載 ECDC 4 個 RSS feeds 並合併為單一 JSONL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

LAYER_NAME="ecdc_cdtr"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

# RSS Feed definitions (using parallel arrays for Bash 3.2 compatibility)
FEED_NAMES=(cdtr epidemiological risk_assessment news)
FEED_URLS=(
    "https://www.ecdc.europa.eu/en/taxonomy/term/1505/feed"
    "https://www.ecdc.europa.eu/en/taxonomy/term/1310/feed"
    "https://www.ecdc.europa.eu/en/taxonomy/term/1295/feed"
    "https://www.ecdc.europa.eu/en/taxonomy/term/1307/feed"
)

mkdir -p "$RAW_DIR"

echo "📥 [$LAYER_NAME] 開始擷取 ECDC RSS feeds..."

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
MERGED_JSONL="$RAW_DIR/merged-$TIMESTAMP.jsonl"
TOTAL_ITEMS=0
FAILED_COUNT=0

# 清空合併檔案
> "$MERGED_JSONL"

# 逐一處理每個 feed
for i in "${!FEED_NAMES[@]}"; do
    feed_name="${FEED_NAMES[$i]}"
    feed_url="${FEED_URLS[$i]}"
    xml_file="$RAW_DIR/rss-${feed_name}-$TIMESTAMP.xml"

    echo "📥 [$LAYER_NAME] 下載 $feed_name feed..."

    # 下載 RSS
    if ! rss_fetch "$feed_url" "$xml_file"; then
        echo "⚠️  [$LAYER_NAME] $feed_name feed 下載失敗，跳過" >&2
        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi

    # 驗證 RSS
    if ! rss_validate "$xml_file"; then
        echo "⚠️  [$LAYER_NAME] $feed_name feed 格式無效，跳過" >&2
        FAILED_COUNT=$((FAILED_COUNT + 1))
        rm -f "$xml_file"
        continue
    fi

    # 轉換為 JSONL 並加入 feed_source 欄位
    item_count=$(rss_count_items "$xml_file")
    echo "📊 [$LAYER_NAME] $feed_name: $item_count 筆"

    # 轉換並附加 feed_source
    rss_extract_items_jsonl "$xml_file" | while IFS= read -r line; do
        # 使用 jq 加入 feed_source 欄位
        echo "$line" | jq -c --arg src "$feed_name" '. + {feed_source: $src}'
    done >> "$MERGED_JSONL"

    TOTAL_ITEMS=$((TOTAL_ITEMS + item_count))
done

# 統計結果
MERGED_COUNT=$(wc -l < "$MERGED_JSONL" | tr -d ' ')

echo ""
echo "📊 [$LAYER_NAME] 合併結果:"
echo "   - 成功 feeds: $((${#FEED_NAMES[@]} - FAILED_COUNT))/${#FEED_NAMES[@]}"
echo "   - 合併筆數: $MERGED_COUNT"

if [[ $FAILED_COUNT -gt 0 ]]; then
    echo "   - 失敗 feeds: $FAILED_COUNT"
fi

# 去重（by link）
if [[ $MERGED_COUNT -gt 0 ]]; then
    DEDUP_JSONL="$RAW_DIR/dedup-$TIMESTAMP.jsonl"
    sort -u -t'"' -k4 "$MERGED_JSONL" > "$DEDUP_JSONL"
    DEDUP_COUNT=$(wc -l < "$DEDUP_JSONL" | tr -d ' ')

    if [[ $DEDUP_COUNT -lt $MERGED_COUNT ]]; then
        echo "   - 去重後: $DEDUP_COUNT 筆（移除 $((MERGED_COUNT - DEDUP_COUNT)) 重複）"
        mv "$DEDUP_JSONL" "$MERGED_JSONL"
    else
        rm -f "$DEDUP_JSONL"
    fi
fi

# 記錄最後擷取時間
echo "$(date -Iseconds)" > "$RAW_DIR/.last_fetch"

echo ""
echo "✅ [$LAYER_NAME] Fetch 完成: $MERGED_JSONL"
