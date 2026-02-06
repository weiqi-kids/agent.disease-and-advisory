#!/bin/bash
# generate-pages-index.sh
# 為 GitHub Pages 生成所有 index.md 檔案

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
EXTRACTOR_DIR="$DOCS_DIR/Extractor"

# Layer 中英文名稱對照
declare_layer_names() {
    # 使用 parallel arrays (Bash 3.2 compatible)
    LAYER_KEYS=(
        "who_disease_outbreak_news"
        "us_cdc_han"
        "us_cdc_mmwr"
        "us_travel_health_notices"
        "ecdc_cdtr"
        "uk_ukhsa_updates"
        "tw_cdc_alerts"
    )
    LAYER_NAMES=(
        "WHO Disease Outbreak News"
        "US CDC Health Alert Network"
        "US CDC MMWR"
        "US Travel Health Notices"
        "ECDC CDTR"
        "UK UKHSA Updates"
        "Taiwan CDC Alerts"
    )
    LAYER_DESCS=(
        "世界衛生組織疾病爆發新聞"
        "美國 CDC 健康警報網絡"
        "美國 CDC 發病率與死亡率週報"
        "美國 CDC 旅遊健康通知"
        "歐洲疾病預防控制中心傳染病威脅報告"
        "英國健康安全局更新"
        "台灣疾管署警報"
    )
}

# 取得 Layer 名稱
get_layer_name() {
    local key="$1"
    for i in "${!LAYER_KEYS[@]}"; do
        if [ "${LAYER_KEYS[$i]}" = "$key" ]; then
            echo "${LAYER_NAMES[$i]}"
            return
        fi
    done
    echo "$key"
}

# 取得 Layer 描述
get_layer_desc() {
    local key="$1"
    for i in "${!LAYER_KEYS[@]}"; do
        if [ "${LAYER_KEYS[$i]}" = "$key" ]; then
            echo "${LAYER_DESCS[$i]}"
            return
        fi
    done
    echo ""
}

# 統計目錄中的 .md 檔案數（排除 index.md）
count_md_files() {
    local dir="$1"
    find "$dir" -maxdepth 1 -name "*.md" -type f ! -name "index.md" 2>/dev/null | wc -l | tr -d ' '
}

# 生成 Layer index.md
generate_layer_index() {
    local layer_dir="$1"
    local layer_key=$(basename "$layer_dir")
    local layer_name=$(get_layer_name "$layer_key")
    local layer_desc=$(get_layer_desc "$layer_key")
    local index_file="$layer_dir/index.md"
    local nav_order=1

    echo "  生成 Layer index: $layer_key"

    cat > "$index_file" << EOF
---
title: $layer_name
layout: default
parent: 資料來源
has_children: true
nav_order: $nav_order
---

# $layer_name

$layer_desc

---

## 分類

| Category | 數量 |
|----------|------|
EOF

    # 列出所有 category
    for cat_dir in "$layer_dir"/*/; do
        [ -d "$cat_dir" ] || continue
        local cat_name=$(basename "$cat_dir")
        [ "$cat_name" = "raw" ] && continue

        local count=$(count_md_files "$cat_dir")
        # 處理年份子目錄
        for year_dir in "$cat_dir"/*/; do
            [ -d "$year_dir" ] || continue
            local year_count=$(count_md_files "$year_dir")
            count=$((count + year_count))
        done

        echo "| [$cat_name]($cat_name/) | $count |" >> "$index_file"
    done
}

# 生成 Category index.md（含檔案列表）
generate_category_index() {
    local cat_dir="$1"
    local layer_dir=$(dirname "$cat_dir")
    local cat_name=$(basename "$cat_dir")
    local layer_key=$(basename "$layer_dir")
    local layer_name=$(get_layer_name "$layer_key")
    local index_file="$cat_dir/index.md"

    echo "    生成 Category index: $cat_name"

    cat > "$index_file" << EOF
---
title: $cat_name
layout: default
parent: $layer_name
has_children: true
---

# $cat_name

---

EOF

    # 檢查是否有年份子目錄
    local has_years=false
    for year_dir in "$cat_dir"/*/; do
        [ -d "$year_dir" ] || continue
        local year_name=$(basename "$year_dir")
        if [[ "$year_name" =~ ^[0-9]{4}$ ]]; then
            has_years=true
            break
        fi
    done

    if [ "$has_years" = true ]; then
        # 有年份子目錄，列出年份
        echo "## 依年份" >> "$index_file"
        echo "" >> "$index_file"
        echo "| 年份 | 數量 |" >> "$index_file"
        echo "|------|------|" >> "$index_file"

        for year_dir in "$cat_dir"/*/; do
            [ -d "$year_dir" ] || continue
            local year_name=$(basename "$year_dir")
            [[ "$year_name" =~ ^[0-9]{4}$ ]] || continue

            local count=$(count_md_files "$year_dir")
            echo "| [$year_name]($year_name/) | $count |" >> "$index_file"
        done
    else
        # 無年份子目錄，列出所有檔案
        echo "## 文章列表" >> "$index_file"
        echo "" >> "$index_file"
        echo "| 日期 | 標題 |" >> "$index_file"
        echo "|------|------|" >> "$index_file"

        # 按日期倒序列出
        for md_file in $(ls -1 "$cat_dir"/*.md 2>/dev/null | sort -r); do
            [ -f "$md_file" ] || continue
            local filename=$(basename "$md_file")
            [ "$filename" = "index.md" ] && continue

            local basename_no_ext="${filename%.md}"
            local date=$(echo "$basename_no_ext" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")
            local title=$(grep -m1 '^title:' "$md_file" 2>/dev/null | sed 's/^title: *//' | sed 's/"//g' | cut -c1-80 || echo "$basename_no_ext")
            [ -z "$title" ] && title="$basename_no_ext"

            echo "| $date | [$title]($basename_no_ext/) |" >> "$index_file"
        done
    fi
}

# 生成年份 index.md
generate_year_index() {
    local year_dir="$1"
    local cat_dir=$(dirname "$year_dir")
    local year_name=$(basename "$year_dir")
    local cat_name=$(basename "$cat_dir")
    local layer_dir=$(dirname "$cat_dir")
    local layer_key=$(basename "$layer_dir")
    local layer_name=$(get_layer_name "$layer_key")
    local index_file="$year_dir/index.md"

    echo "      生成 Year index: $year_name"

    cat > "$index_file" << EOF
---
title: "$year_name"
layout: default
parent: $cat_name
grand_parent: $layer_name
---

# $cat_name - $year_name

---

## 文章列表

| 日期 | 標題 |
|------|------|
EOF

    # 按日期倒序列出
    for md_file in $(ls -1 "$year_dir"/*.md 2>/dev/null | sort -r); do
        [ -f "$md_file" ] || continue
        local filename=$(basename "$md_file")
        [ "$filename" = "index.md" ] && continue

        local basename_no_ext="${filename%.md}"
        local date=$(echo "$basename_no_ext" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")
        local title=$(grep -m1 '^title:' "$md_file" 2>/dev/null | sed 's/^title: *//' | sed 's/"//g' | cut -c1-80 || echo "$basename_no_ext")
        [ -z "$title" ] && title="$basename_no_ext"

        echo "| $date | [$title]($basename_no_ext/) |" >> "$index_file"
    done
}

# 處理 MMWR 年份分組
organize_mmwr_by_year() {
    local mmwr_dir="$EXTRACTOR_DIR/us_cdc_mmwr"

    echo "處理 MMWR 年份分組..."

    for cat_dir in "$mmwr_dir"/*/; do
        [ -d "$cat_dir" ] || continue
        local cat_name=$(basename "$cat_dir")
        [ "$cat_name" = "raw" ] && continue

        echo "  處理 category: $cat_name"

        # 掃描所有 .md 檔案，按年份分組
        for md_file in "$cat_dir"/*.md; do
            [ -f "$md_file" ] || continue
            local filename=$(basename "$md_file")
            [ "$filename" = "index.md" ] && continue

            # 從檔名提取年份
            local year=$(echo "$filename" | grep -oE '^[0-9]{4}' || echo "")
            if [ -z "$year" ]; then
                # 嘗試從 frontmatter 的 date 欄位提取
                year=$(grep -m1 '^date:' "$md_file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1 || echo "unknown")
            fi

            if [ -n "$year" ] && [ "$year" != "unknown" ]; then
                local year_dir="$cat_dir/$year"
                mkdir -p "$year_dir"
                mv "$md_file" "$year_dir/"
            fi
        done
    done
}

# 生成週報 index.md
generate_weekly_digest_index() {
    local digest_dir="$DOCS_DIR/Narrator/weekly_digest"
    local index_file="$digest_dir/index.md"

    echo "生成週報 index..."

    cat > "$index_file" << EOF
---
title: 週報摘要
layout: default
parent: 報告
has_children: true
---

# 週報摘要

每週傳染病威脅綜合分析報告。

---

## 歷史週報

| 週次 | 標題 |
|------|------|
EOF

    # 按檔名倒序列出（週次越近越前）
    for md_file in $(ls -1 "$digest_dir"/*.md 2>/dev/null | sort -r); do
        [ -f "$md_file" ] || continue
        local filename=$(basename "$md_file")
        [ "$filename" = "index.md" ] && continue

        local basename_no_ext="${filename%.md}"
        local week=$(echo "$basename_no_ext" | grep -oE '^[0-9]{4}-W[0-9]{2}' || echo "")
        local title=$(grep -m1 '^# ' "$md_file" 2>/dev/null | sed 's/^# //' || echo "$basename_no_ext")

        echo "| $week | [$title]($basename_no_ext/) |" >> "$index_file"
    done
}

# 主程式
main() {
    echo "=== 開始生成 Pages index ==="

    declare_layer_names

    # 1. 處理 MMWR 年份分組（先做這個，因為會移動檔案）
    organize_mmwr_by_year

    # 2. 生成各 Layer 的 index
    echo ""
    echo "生成 Layer index..."
    for layer_dir in "$EXTRACTOR_DIR"/*/; do
        [ -d "$layer_dir" ] || continue
        local layer_name=$(basename "$layer_dir")
        [ "$layer_name" = "raw" ] && continue

        generate_layer_index "$layer_dir"

        # 3. 生成各 Category 的 index
        for cat_dir in "$layer_dir"/*/; do
            [ -d "$cat_dir" ] || continue
            local cat_name=$(basename "$cat_dir")
            [ "$cat_name" = "raw" ] && continue

            generate_category_index "$cat_dir"

            # 4. 生成年份 index（如果有）
            for year_dir in "$cat_dir"/*/; do
                [ -d "$year_dir" ] || continue
                local year_name=$(basename "$year_dir")
                [[ "$year_name" =~ ^[0-9]{4}$ ]] || continue

                generate_year_index "$year_dir"
            done
        done
    done

    # 5. 生成週報 index
    echo ""
    generate_weekly_digest_index

    echo ""
    echo "=== 完成 ==="
}

main "$@"
