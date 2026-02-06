#!/bin/bash
# fix-broken-links.sh
# 自動修復常見的連結錯誤

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FIXED_COUNT=0
UNFIXABLE=()

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 修復類型 1：移除尾部斜線
fix_trailing_slash() {
    local file="$1"
    local count=0

    # 找出 markdown 連結中帶尾部斜線的（排除目錄連結）
    # 模式：](something/) 但不是 ](http 或 ](/ 開頭的絕對路徑
    if grep -qE '\]\([^h/][^)]*[^/]/\)' "$file" 2>/dev/null; then
        # 備份並修復
        sed -i.bak -E 's/\]\(([^h/][^)]*[^/])\/\)/](\1)/g' "$file"
        rm -f "${file}.bak"
        count=$(grep -cE '\]\([^h/][^)]*[^/]/\)' "$file" 2>/dev/null || echo 0)
        if [[ "$count" == "0" ]]; then
            ((FIXED_COUNT++))
            return 0
        fi
    fi
    return 1
}

# 修復類型 2：相對路徑缺少 baseurl
fix_missing_baseurl() {
    local file="$1"
    # Jekyll 的 baseurl 問題通常在模板處理，這裡只標記
    return 1
}

# 修復類型 3：檔案已移動或重命名
fix_moved_file() {
    local file="$1"
    local broken_link="$2"
    local dir=$(dirname "$file")

    # 嘗試找相似檔名
    local basename=$(basename "$broken_link" | sed 's/\/$//; s/\.md$//; s/\.html$//')
    local found=$(find "$DOCS_DIR" -name "*${basename}*" -type f 2>/dev/null | head -1)

    if [[ -n "$found" ]]; then
        log_warn "可能的替代檔案: $found"
        return 1  # 需要人工確認
    fi
    return 1
}

# 掃描並修復所有 index.md 中的連結
fix_index_files() {
    log_info "掃描 index.md 檔案..."

    while IFS= read -r index_file; do
        [[ -f "$index_file" ]] || continue

        # 檢查是否有尾部斜線問題
        if grep -qE '\|\s*\[[^\]]+\]\([^)]+/\)\s*\|' "$index_file" 2>/dev/null; then
            log_info "修復: $index_file"
            # 修復表格中的連結尾部斜線
            sed -i.bak -E 's/\]\(([^)]+)\/\)\s*\|/](\1) |/g' "$index_file"
            rm -f "${index_file}.bak"
            ((FIXED_COUNT++))
        fi
    done < <(find "$DOCS_DIR" -name "index.md" -type f)
}

# 檢查 lychee 報告並嘗試修復
process_lychee_report() {
    local report="$1"

    if [[ ! -f "$report" ]]; then
        log_warn "找不到 lychee 報告: $report"
        return 0
    fi

    log_info "分析 lychee 報告..."

    # 解析報告中的錯誤連結
    while IFS= read -r line; do
        # lychee 報告格式: [404] https://... (in file.md)
        if [[ "$line" =~ \[([0-9]+)\]\ (.+)\ \(in\ (.+)\) ]]; then
            local status="${BASH_REMATCH[1]}"
            local url="${BASH_REMATCH[2]}"
            local source_file="${BASH_REMATCH[3]}"

            # 內部連結（相對路徑）才嘗試修復
            if [[ "$url" =~ ^https://weiqi-kids\.github\.io ]]; then
                # 檢查是否是尾部斜線問題
                if [[ "$url" =~ /$ ]] && [[ ! "$url" =~ /index\.html$ ]]; then
                    local clean_url="${url%/}"
                    log_info "嘗試修復尾部斜線: $url → $clean_url"
                    # 在原始檔案中替換
                    if [[ -f "$source_file" ]]; then
                        local escaped_url=$(echo "$url" | sed 's/[\/&]/\\&/g')
                        local escaped_clean=$(echo "$clean_url" | sed 's/[\/&]/\\&/g')
                        sed -i.bak "s|${escaped_url}|${escaped_clean}|g" "$source_file"
                        rm -f "${source_file}.bak"
                        ((FIXED_COUNT++))
                    fi
                else
                    UNFIXABLE+=("$status $url (in $source_file)")
                fi
            else
                # 外部連結無法自動修復
                UNFIXABLE+=("$status $url (in $source_file)")
            fi
        fi
    done < "$report"
}

# 主程式
main() {
    log_info "=== 開始自動修復連結 ==="

    # 1. 修復已知模式
    fix_index_files

    # 2. 如果有 lychee 報告，處理它
    if [[ -f "$PROJECT_ROOT/lychee-report.md" ]]; then
        process_lychee_report "$PROJECT_ROOT/lychee-report.md"
    fi

    # 3. 報告結果
    echo ""
    log_info "=== 修復完成 ==="
    log_info "已修復: $FIXED_COUNT 個問題"

    if [[ ${#UNFIXABLE[@]} -gt 0 ]]; then
        log_warn "無法自動修復的連結 (${#UNFIXABLE[@]} 個):"
        for item in "${UNFIXABLE[@]}"; do
            echo "  - $item"
        done

        # 輸出到檔案供 Issue 使用
        echo "## 無法自動修復的連結" > "$PROJECT_ROOT/unfixable-links.md"
        echo "" >> "$PROJECT_ROOT/unfixable-links.md"
        echo "| 狀態 | 連結 | 來源檔案 |" >> "$PROJECT_ROOT/unfixable-links.md"
        echo "|------|------|----------|" >> "$PROJECT_ROOT/unfixable-links.md"
        for item in "${UNFIXABLE[@]}"; do
            if [[ "$item" =~ ^([0-9]+)\ (.+)\ \(in\ (.+)\)$ ]]; then
                echo "| ${BASH_REMATCH[1]} | ${BASH_REMATCH[2]} | ${BASH_REMATCH[3]} |" >> "$PROJECT_ROOT/unfixable-links.md"
            fi
        done

        exit 1  # 有無法修復的問題
    fi

    exit 0
}

main "$@"
