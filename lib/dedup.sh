#!/usr/bin/env bash
# dedup.sh - 高效去重工具
# 使用 comm 批次比對，避免逐行 grep 的 O(n²) 問題

if [[ -n "${DEDUP_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
DEDUP_SH_LOADED=1

########################################
# dedup_find_new_items JSONL_FILE LAYER_DIR [URL_FIELD]
#
# 功能：
#   - 找出 JSONL 中尚未萃取的新資料行號
#   - 使用 comm 批次比對，效率 O(n log n)
#
# 參數：
#   JSONL_FILE: 原始資料檔案
#   LAYER_DIR:  萃取結果目錄（如 docs/Extractor/us_cdc_mmwr）
#   URL_FIELD:  JSONL 中的 URL 欄位名（預設 "link"）
#
# stdout:
#   每行一個行號（1-based）
#
# 範例：
#   dedup_find_new_items raw/data.jsonl docs/Extractor/layer_name
#   # 輸出: 1, 5, 12 （表示第 1, 5, 12 行是新資料）
########################################
dedup_find_new_items() {
  local jsonl_file="$1"
  local layer_dir="$2"
  local url_field="${3:-link}"

  if [[ ! -f "$jsonl_file" ]]; then
    echo "❌ [dedup] JSONL 檔案不存在: $jsonl_file" >&2
    return 1
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  # 1. 提取已萃取的 URL（從 .md 檔案的 frontmatter）
  grep -rh "^source_url:" "$layer_dir"/*/ 2>/dev/null \
    | sed 's/source_url: //' \
    | tr -d '"' \
    | sort -u > "$tmp_dir/existing.txt"

  # 2. 使用 awk 一次提取 JSONL 中的 URL 和行號（高效）
  awk -F'"' -v field="$url_field" '
    {
      for (i=1; i<NF; i++) {
        if ($i == field && $(i+1) == ":") {
          url = $(i+2)
          if (url != "") {
            print url "\t" NR
          }
          break
        }
      }
    }
  ' "$jsonl_file" > "$tmp_dir/jsonl_urls.txt"

  # 3. 提取唯一 URL 並排序
  cut -f1 "$tmp_dir/jsonl_urls.txt" | sort -u > "$tmp_dir/new_urls.txt"

  # 4. 找出新 URL（在 new 但不在 existing 中）
  comm -23 "$tmp_dir/new_urls.txt" "$tmp_dir/existing.txt" > "$tmp_dir/diff_urls.txt"

  # 5. 使用 awk 高效匹配行號
  if [[ -s "$tmp_dir/diff_urls.txt" ]]; then
    awk -F'\t' 'NR==FNR {urls[$1]=1; next} $1 in urls {print $2}' \
      "$tmp_dir/diff_urls.txt" "$tmp_dir/jsonl_urls.txt" | sort -n | uniq
  fi

  # 清理
  rm -rf "$tmp_dir"
}

########################################
# dedup_count_new JSONL_FILE LAYER_DIR [URL_FIELD]
#
# 功能：
#   - 計算新資料數量（不輸出行號）
#
# stdout:
#   新資料數量（整數）
########################################
dedup_count_new() {
  dedup_find_new_items "$@" | wc -l | tr -d ' '
}

########################################
# dedup_extract_lines JSONL_FILE LINE_NUMBERS_FILE
#
# 功能：
#   - 根據行號檔案提取 JSONL 中的對應行
#
# 參數：
#   JSONL_FILE: 原始資料檔案
#   LINE_NUMBERS_FILE: 包含行號的檔案（每行一個）
#
# stdout:
#   對應的 JSON 行
########################################
dedup_extract_lines() {
  local jsonl_file="$1"
  local lines_file="$2"

  if [[ ! -f "$jsonl_file" ]] || [[ ! -f "$lines_file" ]]; then
    return 1
  fi

  # 使用 awk 高效提取指定行
  awk 'NR==FNR {lines[$1]=1; next} FNR in lines' "$lines_file" "$jsonl_file"
}

########################################
# dedup_batch_info JSONL_FILE LAYER_DIR [BATCH_SIZE]
#
# 功能：
#   - 輸出批次處理資訊，供萃取 Task 使用
#
# 參數：
#   JSONL_FILE: 原始資料檔案
#   LAYER_DIR:  萃取結果目錄
#   BATCH_SIZE: 每批數量（預設 10）
#
# stdout:
#   JSON 格式的批次資訊
########################################
dedup_batch_info() {
  local jsonl_file="$1"
  local layer_dir="$2"
  local batch_size="${3:-10}"

  local tmp_file
  tmp_file="$(mktemp)"

  dedup_find_new_items "$jsonl_file" "$layer_dir" > "$tmp_file"

  local total
  total=$(wc -l < "$tmp_file" | tr -d ' ')

  local batch_count=$(( (total + batch_size - 1) / batch_size ))

  echo "{"
  echo "  \"jsonl_file\": \"$jsonl_file\","
  echo "  \"layer_dir\": \"$layer_dir\","
  echo "  \"total_new\": $total,"
  echo "  \"batch_size\": $batch_size,"
  echo "  \"batch_count\": $batch_count,"
  echo "  \"line_numbers\": [$(paste -sd, "$tmp_file")]"
  echo "}"

  rm -f "$tmp_file"
}
