#!/usr/bin/env bash

###############################################
# html.sh
# HTML 轉換工具函式：
#   - html_convert_md <md_file> [output_html]  將 Markdown 轉為 HTML
#
# 使用方式：
#   source ./lib/html.sh
#   html_convert_md docs/Narrator/weekly_digest/2026-W05-weekly-digest.md
#
# 注意：
#   - 此檔案預期被其他腳本以 `source` 載入
#   - 需要 pandoc 3.x 以上版本
###############################################

# 避免被重複載入
if [[ -n "${HTML_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
HTML_SH_LOADED=1

# 取得 lib 目錄路徑
_html_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_html_project_root="$(cd "$_html_lib_dir/.." && pwd)"

# 載入 core.sh 以使用 require_cmd
if [[ -z "${CORE_SH_LOADED:-}" ]]; then
  source "$_html_lib_dir/core.sh"
fi

# HTML 模板路徑
HTML_TEMPLATE="$_html_lib_dir/html-template.html"

# html_convert_md - 將 Markdown 檔案轉換為 HTML
#
# 用法：
#   html_convert_md <md_file> [output_html]
#
# 參數：
#   md_file      - 要轉換的 Markdown 檔案路徑
#   output_html  - 輸出的 HTML 檔案路徑（選填，預設為同目錄同名 .html）
#
# 範例：
#   html_convert_md docs/Narrator/weekly_digest/2026-W05-weekly-digest.md
#   html_convert_md report.md custom-output.html
#
html_convert_md() {
  local md_file="$1"
  local output_html="${2:-}"

  # 檢查參數
  if [[ -z "$md_file" ]]; then
    echo "❌ 錯誤：未指定 Markdown 檔案" >&2
    echo "用法：html_convert_md <md_file> [output_html]" >&2
    return 1
  fi

  # 檢查檔案存在
  if [[ ! -f "$md_file" ]]; then
    echo "❌ 錯誤：找不到檔案 $md_file" >&2
    return 1
  fi

  # 檢查 pandoc
  require_cmd pandoc

  # 檢查模板存在
  if [[ ! -f "$HTML_TEMPLATE" ]]; then
    echo "❌ 錯誤：找不到 HTML 模板 $HTML_TEMPLATE" >&2
    return 1
  fi

  # 若未指定輸出路徑，使用同目錄同名 .html
  if [[ -z "$output_html" ]]; then
    output_html="${md_file%.md}.html"
  fi

  # 從 Markdown 檔案提取標題（第一個 # 開頭的行）
  local title
  title=$(grep -m1 '^# ' "$md_file" | sed 's/^# //' || echo "Report")

  # 執行轉換
  if pandoc "$md_file" \
    --from=gfm \
    --to=html5 \
    --standalone \
    --template="$HTML_TEMPLATE" \
    --metadata title="$title" \
    --output="$output_html"; then
    echo "✅ HTML 產出：$output_html"
    return 0
  else
    echo "❌ 轉換失敗：$md_file" >&2
    return 1
  fi
}

# html_convert_all_in_dir - 轉換目錄下所有 Markdown 檔案
#
# 用法：
#   html_convert_all_in_dir <directory>
#
html_convert_all_in_dir() {
  local dir="$1"
  local count=0
  local failed=0

  if [[ -z "$dir" || ! -d "$dir" ]]; then
    echo "❌ 錯誤：無效的目錄 $dir" >&2
    return 1
  fi

  for md_file in "$dir"/*.md; do
    [[ -f "$md_file" ]] || continue
    if html_convert_md "$md_file"; then
      ((count++))
    else
      ((failed++))
    fi
  done

  echo "轉換完成：成功 $count 筆，失敗 $failed 筆"
  [[ $failed -eq 0 ]]
}
