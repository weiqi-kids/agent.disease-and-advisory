#!/usr/bin/env bash
# api.sh - JSON API 擷取工具
# 注意：預期被其他 script 用 `source` 載入
# 不在這裡 set -euo pipefail，交給呼叫端決定。

if [[ -n "${API_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
API_SH_LOADED=1

_api_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${_api_lib_dir}/core.sh"

########################################
# api_fetch_json URL OUTPUT_FILE
#
# 功能：
#   - 從指定 URL 下載 JSON 資料
#
# 參數：
#   URL: API endpoint URL
#   OUTPUT_FILE: 輸出檔案路徑
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
########################################
api_fetch_json() {
  local url="$1"
  local output_file="$2"

  require_cmd curl || return 1
  require_cmd jq || return 1

  local max_retries=3
  local retry_delay=2
  local http_code

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    http_code="$(
      curl -sS -L \
        -H "User-Agent: DiseaseIntelligenceSystem/1.0" \
        -H "Accept: application/json" \
        -w '%{http_code}' \
        -o "$output_file" \
        --connect-timeout 15 \
        --max-time 120 \
        "$url" 2>/dev/null
    )" || {
      local rc=$?
      if [[ $attempt -lt $max_retries ]]; then
        echo "⚠️  [api_fetch_json] curl 失敗 (exit=$rc)，重試 $attempt/$max_retries..." >&2
        sleep $retry_delay
        continue
      fi
      echo "❌ [api_fetch_json] curl 失敗 (exit=$rc)，已重試 $max_retries 次" >&2
      return 1
    }

    if [[ "$http_code" == "200" ]]; then
      # 驗證是否為有效 JSON
      if jq empty "$output_file" 2>/dev/null; then
        return 0
      else
        echo "❌ [api_fetch_json] 回應不是有效的 JSON" >&2
        return 1
      fi
    fi

    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [api_fetch_json] HTTP=${http_code}，重試 $attempt/$max_retries..." >&2
      sleep $retry_delay
    else
      echo "❌ [api_fetch_json] HTTP=${http_code}，已重試 $max_retries 次" >&2
      rm -f "$output_file"
      return 1
    fi
  done

  return 1
}

########################################
# api_fetch_odata URL OUTPUT_FILE [TOP] [SKIP]
#
# 功能：
#   - 從 OData API 下載資料並轉為 JSONL
#   - 支援分頁參數 $top 和 $skip
#
# 參數：
#   URL: OData API endpoint URL
#   OUTPUT_FILE: 輸出 JSONL 檔案路徑
#   TOP: 每次取得筆數（預設 100）
#   SKIP: 跳過筆數（預設 0）
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
########################################
api_fetch_odata() {
  local base_url="$1"
  local output_file="$2"
  local top="${3:-100}"
  local skip="${4:-0}"

  require_cmd curl || return 1
  require_cmd jq || return 1

  local tmp_json
  tmp_json="$(mktemp)"
  trap "rm -f '$tmp_json'" RETURN

  # 構建 OData URL
  local separator="?"
  [[ "$base_url" == *"?"* ]] && separator="&"
  local url="${base_url}${separator}\$top=${top}&\$skip=${skip}"

  # 下載 JSON
  if ! api_fetch_json "$url" "$tmp_json"; then
    return 1
  fi

  # 轉換為 JSONL（假設 OData 回應的資料在 value 陣列中）
  if jq -e '.value' "$tmp_json" >/dev/null 2>&1; then
    jq -c '.value[]' "$tmp_json" > "$output_file"
  else
    # 如果沒有 value 欄位，嘗試直接處理為陣列
    jq -c '.[]' "$tmp_json" > "$output_file" 2>/dev/null || {
      # 如果不是陣列，當作單一物件
      jq -c '.' "$tmp_json" > "$output_file"
    }
  fi

  return 0
}

########################################
# api_fetch_odata_all URL OUTPUT_FILE [PAGE_SIZE]
#
# 功能：
#   - 自動分頁下載所有 OData 資料
#   - 合併所有分頁結果到單一 JSONL
#
# 參數：
#   URL: OData API endpoint URL
#   OUTPUT_FILE: 輸出 JSONL 檔案路徑
#   PAGE_SIZE: 每頁筆數（預設 100）
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
########################################
api_fetch_odata_all() {
  local base_url="$1"
  local output_file="$2"
  local page_size="${3:-100}"

  require_cmd curl || return 1
  require_cmd jq || return 1

  local tmp_page
  tmp_page="$(mktemp)"
  trap "rm -f '$tmp_page'" RETURN

  local skip=0
  local total_count=0

  # 清空輸出檔
  > "$output_file"

  while true; do
    echo "📥 [api_fetch_odata_all] 下載 skip=$skip, top=$page_size..." >&2

    if ! api_fetch_odata "$base_url" "$tmp_page" "$page_size" "$skip"; then
      if [[ $total_count -gt 0 ]]; then
        echo "⚠️  [api_fetch_odata_all] 分頁 $skip 失敗，已取得 $total_count 筆" >&2
        return 0
      fi
      return 1
    fi

    local page_count
    page_count="$(wc -l < "$tmp_page" | tr -d ' ')"

    if [[ "$page_count" -eq 0 ]]; then
      break
    fi

    cat "$tmp_page" >> "$output_file"
    total_count=$((total_count + page_count))
    skip=$((skip + page_size))

    # 如果取得的數量少於 page_size，表示已到最後一頁
    if [[ "$page_count" -lt "$page_size" ]]; then
      break
    fi
  done

  echo "✅ [api_fetch_odata_all] 共取得 $total_count 筆" >&2
  return 0
}

########################################
# api_count_items JSONL_FILE
#
# 功能：
#   - 計算 JSONL 檔案中的項目數量
#
# 參數：
#   JSONL_FILE: JSONL 檔案路徑
#
# stdout:
#   項目數量（整數）
########################################
api_count_items() {
  local jsonl_file="$1"

  if [[ ! -f "$jsonl_file" ]]; then
    echo "0"
    return 1
  fi

  wc -l < "$jsonl_file" | tr -d ' '
}

########################################
# api_extract_preview JSONL_FILE [LIMIT]
#
# 功能：
#   - 預覽 JSONL 檔案中的項目
#   - 顯示每個項目的主要欄位
#
# 參數：
#   JSONL_FILE: JSONL 檔案路徑
#   LIMIT: 顯示筆數（預設 5）
#
# stdout:
#   格式化的預覽輸出
########################################
api_extract_preview() {
  local jsonl_file="$1"
  local limit="${2:-5}"

  require_cmd jq || return 1

  if [[ ! -f "$jsonl_file" ]]; then
    echo "❌ [api_extract_preview] 檔案不存在：$jsonl_file" >&2
    return 1
  fi

  head -n "$limit" "$jsonl_file" | while IFS= read -r line; do
    echo "$line" | jq -r '
      "---",
      "Title: \(.title // .Title // .name // .Name // "N/A")",
      "Date: \(.date // .Date // .pubDate // .PublicationDate // "N/A")",
      "Link: \(.link // .Link // .url // .Url // "N/A")"
    ' 2>/dev/null || echo "解析失敗：$line"
    echo ""
  done
}

########################################
# api_validate_jsonl JSONL_FILE
#
# 功能：
#   - 驗證 JSONL 檔案格式
#
# 參數：
#   JSONL_FILE: JSONL 檔案路徑
#
# 回傳值：
#   0  = 有效
#   1  = 無效（包含無效的 JSON 行）
########################################
api_validate_jsonl() {
  local jsonl_file="$1"
  local line_num=0
  local errors=0

  require_cmd jq || return 1

  if [[ ! -f "$jsonl_file" ]]; then
    echo "❌ [api_validate_jsonl] 檔案不存在：$jsonl_file" >&2
    return 1
  fi

  while IFS= read -r line; do
    line_num=$((line_num + 1))
    if ! echo "$line" | jq empty 2>/dev/null; then
      echo "❌ [api_validate_jsonl] 第 $line_num 行不是有效的 JSON" >&2
      errors=$((errors + 1))
    fi
  done < "$jsonl_file"

  if [[ $errors -gt 0 ]]; then
    echo "❌ [api_validate_jsonl] 共有 $errors 行無效" >&2
    return 1
  fi

  return 0
}
