#!/bin/bash
# uk_ukhsa_updates 資料擷取腳本
# 功能:下載 UKHSA 3 個 Atom/RSS feeds 並合併為單一 JSONL
# 相容 Bash 3.2（macOS 預設版本）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

LAYER_NAME="uk_ukhsa_updates"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

# Feed URLs（使用陣列，Bash 3.2 相容）
FEED_NAMES=(
    "ukhsa_official"
    "ukhsa_news"
    "ukhsa_blog"
)

FEED_URLS=(
    "https://www.gov.uk/government/organisations/uk-health-security-agency.atom"
    "https://www.gov.uk/search/news-and-communications.atom?organisations%5B%5D=uk-health-security-agency"
    "https://ukhsa.blog.gov.uk/feed/"
)

mkdir -p "$RAW_DIR"

echo "📥 [$LAYER_NAME] 開始擷取 UKHSA feeds..."

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
MERGED_JSONL="$RAW_DIR/merged-$TIMESTAMP.jsonl"
TOTAL_ITEMS=0
FAILED_FEEDS=()

# 清空合併檔案
> "$MERGED_JSONL"

# Atom 轉 JSONL 函數
atom_extract_items_jsonl() {
    local xml_file="$1"

    require_cmd jq || return 1

    if command -v xmllint >/dev/null 2>&1; then
        # 使用 xmllint 解析 Atom
        local count
        count="$(xmllint --xpath 'count(//*[local-name()="entry"])' "$xml_file" 2>/dev/null)" || return 1

        for ((i=1; i<=count; i++)); do
            local title link description pubDate
            title="$(xmllint --xpath "string(//*[local-name()='entry'][$i]/*[local-name()='title'])" "$xml_file" 2>/dev/null || echo "")"
            link="$(xmllint --xpath "string(//*[local-name()='entry'][$i]/*[local-name()='link']/@href)" "$xml_file" 2>/dev/null || echo "")"
            description="$(xmllint --xpath "string(//*[local-name()='entry'][$i]/*[local-name()='summary'])" "$xml_file" 2>/dev/null || echo "")"

            # 如果 summary 為空，嘗試 content
            if [[ -z "$description" ]]; then
                description="$(xmllint --xpath "string(//*[local-name()='entry'][$i]/*[local-name()='content'])" "$xml_file" 2>/dev/null || echo "")"
            fi

            # 優先使用 updated，其次 published
            pubDate="$(xmllint --xpath "string(//*[local-name()='entry'][$i]/*[local-name()='updated'])" "$xml_file" 2>/dev/null || echo "")"
            if [[ -z "$pubDate" ]]; then
                pubDate="$(xmllint --xpath "string(//*[local-name()='entry'][$i]/*[local-name()='published'])" "$xml_file" 2>/dev/null || echo "")"
            fi

            jq -c -n \
                --arg title "$title" \
                --arg link "$link" \
                --arg description "$description" \
                --arg pubDate "$pubDate" \
                '{title: $title, link: $link, description: $description, pubDate: $pubDate}'
        done
    else
        echo "⚠️  xmllint 不可用，使用簡易解析" >&2
        # 回退到簡易 sed 解析（較不可靠）
        rss_extract_items_jsonl "$xml_file"
    fi
}

# 逐一處理每個 feed
for idx in "${!FEED_NAMES[@]}"; do
    feed_name="${FEED_NAMES[$idx]}"
    feed_url="${FEED_URLS[$idx]}"
    xml_file="$RAW_DIR/feed-${feed_name}-$TIMESTAMP.xml"

    echo "📥 [$LAYER_NAME] 下載 $feed_name feed..."

    # 下載 feed
    if ! rss_fetch "$feed_url" "$xml_file"; then
        echo "⚠️  [$LAYER_NAME] $feed_name feed 下載失敗，跳過" >&2
        FAILED_FEEDS+=("$feed_name")
        continue
    fi

    # 驗證 feed（RSS 或 Atom 都應通過）
    if ! rss_validate "$xml_file"; then
        echo "⚠️  [$LAYER_NAME] $feed_name feed 格式無效，跳過" >&2
        FAILED_FEEDS+=("$feed_name")
        rm -f "$xml_file"
        continue
    fi

    # 判斷是 Atom 還是 RSS
    is_atom=false
    if grep -q '<feed' "$xml_file" 2>/dev/null; then
        is_atom=true
    fi

    # 轉換為 JSONL
    tmp_jsonl="$(mktemp)"

    if [[ "$is_atom" == "true" ]]; then
        atom_extract_items_jsonl "$xml_file" > "$tmp_jsonl"
    else
        rss_extract_items_jsonl "$xml_file" > "$tmp_jsonl"
    fi

    item_count=$(wc -l < "$tmp_jsonl" | tr -d ' ')
    echo "📊 [$LAYER_NAME] $feed_name: $item_count 筆"

    # 加入 feed_source 欄位並合併
    while IFS= read -r line; do
        echo "$line" | jq -c --arg src "$feed_name" '. + {feed_source: $src}'
    done < "$tmp_jsonl" >> "$MERGED_JSONL"

    rm -f "$tmp_jsonl"
    TOTAL_ITEMS=$((TOTAL_ITEMS + item_count))
done

# 統計結果
MERGED_COUNT=$(wc -l < "$MERGED_JSONL" | tr -d ' ')

echo ""
echo "📊 [$LAYER_NAME] 合併結果:"
echo "   - 成功 feeds: $((${#FEED_NAMES[@]} - ${#FAILED_FEEDS[@]}))/${#FEED_NAMES[@]}"
echo "   - 合併筆數: $MERGED_COUNT"

if [[ ${#FAILED_FEEDS[@]} -gt 0 ]]; then
    echo "   - 失敗 feeds: ${FAILED_FEEDS[*]}"
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
