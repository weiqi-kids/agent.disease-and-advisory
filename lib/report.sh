#!/usr/bin/env bash

###############################################
# report.sh
# 報告歷史查詢工具函式：
#   - report_find_previous <mode> [year_week]  取得上一期報告路徑
#   - report_list_all <mode>                   列出所有歷史報告
#   - report_search <mode> <pattern>           搜尋報告內容
#   - report_get_week_number <date>            取得指定日期的週數
#   - report_previous_week <year_week>         計算上一週的 YYYY-WWW
#
# 使用方式：
#   source ./lib/report.sh
#   prev=$(report_find_previous weekly_digest 2026-W05)
#   report_list_all weekly_digest
#   report_search weekly_digest "立百病毒"
#
# 注意：
#   - 此檔案預期被其他腳本以 `source` 載入
#   - 報告命名格式：{YYYY}-W{WW}-{mode_name}.md
###############################################

# 避免被重複載入
if [[ -n "${REPORT_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
REPORT_SH_LOADED=1

# 取得 lib 目錄路徑
_report_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_report_project_root="$(cd "$_report_lib_dir/.." && pwd)"
_report_narrator_dir="$_report_project_root/docs/Narrator"

# report_get_week_number - 取得指定日期的 ISO 週數
#
# 用法：
#   report_get_week_number [date]
#
# 參數：
#   date - 日期字串（選填，預設為今天）
#
# 輸出：
#   YYYY-WWW 格式（如 2026-W05）
#
report_get_week_number() {
  local date_str="${1:-}"

  if [[ -z "$date_str" ]]; then
    # 今天
    date "+%G-W%V"
  else
    # 指定日期（macOS 與 Linux 相容）
    if [[ "$(uname -s)" == "Darwin" ]]; then
      date -j -f "%Y-%m-%d" "$date_str" "+%G-W%V" 2>/dev/null || echo ""
    else
      date -d "$date_str" "+%G-W%V" 2>/dev/null || echo ""
    fi
  fi
}

# report_previous_week - 計算上一週的週數
#
# 用法：
#   report_previous_week <year_week>
#
# 參數：
#   year_week - YYYY-WWW 格式（如 2026-W05）
#
# 輸出：
#   上一週的 YYYY-WWW 格式（如 2026-W04）
#
report_previous_week() {
  local year_week="$1"

  if [[ -z "$year_week" ]]; then
    echo "❌ 錯誤：未指定週數" >&2
    return 1
  fi

  # 解析年份和週數
  local year week
  year=$(echo "$year_week" | sed 's/-W.*//')
  week=$(echo "$year_week" | sed 's/.*-W//' | sed 's/^0//')

  if [[ $week -eq 1 ]]; then
    # 第 1 週 → 上一年最後一週
    local prev_year=$((year - 1))
    # 取得上一年的最後一週（12月28日一定在最後一週）
    local last_week
    if [[ "$(uname -s)" == "Darwin" ]]; then
      last_week=$(date -j -f "%Y-%m-%d" "${prev_year}-12-28" "+%V" 2>/dev/null)
    else
      last_week=$(date -d "${prev_year}-12-28" "+%V" 2>/dev/null)
    fi
    printf "%d-W%02d" "$prev_year" "$last_week"
  else
    # 一般情況：週數減 1
    printf "%d-W%02d" "$year" "$((week - 1))"
  fi
}

# report_find_previous - 取得上一期報告路徑
#
# 用法：
#   report_find_previous <mode> [year_week]
#
# 參數：
#   mode      - Mode 名稱（如 weekly_digest）
#   year_week - 當前週數（選填，預設為本週）
#
# 輸出：
#   上一期報告的完整路徑，若不存在則輸出空字串
#
report_find_previous() {
  local mode="$1"
  local year_week="${2:-$(report_get_week_number)}"

  if [[ -z "$mode" ]]; then
    echo "❌ 錯誤：未指定 Mode" >&2
    return 1
  fi

  local prev_week
  prev_week=$(report_previous_week "$year_week")

  local mode_dir="$_report_narrator_dir/$mode"
  local report_file="$mode_dir/${prev_week}-${mode}.md"

  if [[ -f "$report_file" ]]; then
    echo "$report_file"
  else
    # 嘗試尋找該週的任何報告（處理檔名格式可能不同的情況）
    local found
    found=$(find "$mode_dir" -name "${prev_week}*.md" -type f 2>/dev/null | head -1)
    if [[ -n "$found" ]]; then
      echo "$found"
    fi
  fi
}

# report_list_all - 列出所有歷史報告
#
# 用法：
#   report_list_all <mode> [format]
#
# 參數：
#   mode   - Mode 名稱（如 weekly_digest）
#   format - 輸出格式：path（完整路徑）、name（檔名）、week（週數）
#            預設為 path
#
# 輸出：
#   依時間倒序排列的報告清單
#
report_list_all() {
  local mode="$1"
  local format="${2:-path}"

  if [[ -z "$mode" ]]; then
    echo "❌ 錯誤：未指定 Mode" >&2
    return 1
  fi

  local mode_dir="$_report_narrator_dir/$mode"

  if [[ ! -d "$mode_dir" ]]; then
    echo "❌ 錯誤：Mode 目錄不存在 $mode_dir" >&2
    return 1
  fi

  # 找出所有 .md 報告，依檔名倒序排列（最新在前）
  case "$format" in
    path)
      find "$mode_dir" -name "????-W??-*.md" -type f 2>/dev/null | sort -r
      ;;
    name)
      find "$mode_dir" -name "????-W??-*.md" -type f 2>/dev/null | xargs -I {} basename {} | sort -r
      ;;
    week)
      find "$mode_dir" -name "????-W??-*.md" -type f 2>/dev/null | xargs -I {} basename {} | sed 's/-[^-]*$//' | sort -r | uniq
      ;;
    *)
      echo "❌ 錯誤：不支援的格式 $format" >&2
      return 1
      ;;
  esac
}

# report_search - 搜尋報告內容
#
# 用法：
#   report_search <mode> <pattern> [options]
#
# 參數：
#   mode    - Mode 名稱（如 weekly_digest）
#   pattern - 搜尋關鍵字或正則表達式
#   options - 額外選項：
#             --recent N  只搜尋最近 N 期（預設全部）
#             --context   顯示匹配行的前後文
#
# 輸出：
#   匹配的報告和內容片段
#
report_search() {
  local mode="$1"
  local pattern="$2"
  shift 2

  local recent=""
  local context=""

  # 解析選項
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --recent)
        recent="$2"
        shift 2
        ;;
      --context)
        context="-C 2"
        shift
        ;;
      *)
        shift
        ;;
    esac
  done

  if [[ -z "$mode" || -z "$pattern" ]]; then
    echo "❌ 用法：report_search <mode> <pattern> [--recent N] [--context]" >&2
    return 1
  fi

  local mode_dir="$_report_narrator_dir/$mode"

  if [[ ! -d "$mode_dir" ]]; then
    echo "❌ 錯誤：Mode 目錄不存在 $mode_dir" >&2
    return 1
  fi

  local files
  if [[ -n "$recent" ]]; then
    files=$(find "$mode_dir" -name "????-W??-*.md" -type f 2>/dev/null | sort -r | head -n "$recent")
  else
    files=$(find "$mode_dir" -name "????-W??-*.md" -type f 2>/dev/null | sort -r)
  fi

  if [[ -z "$files" ]]; then
    echo "找不到報告檔案" >&2
    return 1
  fi

  # 執行搜尋
  echo "$files" | xargs grep -l "$pattern" 2>/dev/null | while read -r file; do
    local week
    week=$(basename "$file" | sed 's/-[^-]*$//')
    echo "=== $week ==="
    if [[ -n "$context" ]]; then
      grep $context -n "$pattern" "$file" 2>/dev/null
    else
      grep -n "$pattern" "$file" 2>/dev/null
    fi
    echo ""
  done
}

# report_count - 統計歷史報告數量
#
# 用法：
#   report_count <mode>
#
report_count() {
  local mode="$1"

  if [[ -z "$mode" ]]; then
    echo "❌ 錯誤：未指定 Mode" >&2
    return 1
  fi

  local mode_dir="$_report_narrator_dir/$mode"
  find "$mode_dir" -name "????-W??-*.md" -type f 2>/dev/null | wc -l | tr -d ' '
}

# report_get_range - 取得指定範圍的報告
#
# 用法：
#   report_get_range <mode> <from_week> <to_week>
#
# 參數：
#   mode      - Mode 名稱
#   from_week - 起始週（YYYY-WWW，較早）
#   to_week   - 結束週（YYYY-WWW，較晚）
#
# 輸出：
#   範圍內的報告路徑清單
#
report_get_range() {
  local mode="$1"
  local from_week="$2"
  local to_week="$3"

  if [[ -z "$mode" || -z "$from_week" || -z "$to_week" ]]; then
    echo "❌ 用法：report_get_range <mode> <from_week> <to_week>" >&2
    return 1
  fi

  local mode_dir="$_report_narrator_dir/$mode"

  # 列出所有報告，過濾範圍
  find "$mode_dir" -name "????-W??-*.md" -type f 2>/dev/null | while read -r file; do
    local week
    week=$(basename "$file" | sed 's/-[^-]*$//')
    # 字串比較（YYYY-WWW 格式可直接比較）
    # 使用 [[ ]] 的字串比較：> 和 < 用於字典序
    if [[ ! "$week" < "$from_week" && ! "$week" > "$to_week" ]]; then
      echo "$file"
    fi
  done | sort
}
