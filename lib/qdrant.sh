#!/usr/bin/env bash
# qdrant.sh - Qdrant vector database helper functions
# 注意：預期被其他 script 用 `.` source 進來
# 不在這裡 set -euo pipefail，交給呼叫端決定。

if [[ -n "${QDRANT_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
QDRANT_SH_LOADED=1

_qdrant_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${_qdrant_lib_dir}/core.sh"

########################################
# ID 轉換：字串 → UUID v5
########################################

# _qdrant_id_to_uuid STRING
#
# 功能：
#   - 將任意字串轉為確定性 UUID v5（NAMESPACE_URL）
#   - 若輸入已是 UUID 格式或純數字，原樣回傳
#
# 用途：
#   Qdrant 要求 point ID 為 UUID 或 unsigned int，
#   本函數將 update.sh 產生的字串 ID 自動轉為 UUID。
_qdrant_id_to_uuid() {
  local input="$1"

  # 如果已是 UUID 格式，直接回傳
  if [[ "$input" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    echo "$input"
    return 0
  fi

  # 如果是純數字，直接回傳
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    echo "$input"
    return 0
  fi

  # 使用 Python uuid5 產生確定性 UUID
  python3 -c "import uuid; print(uuid.uuid5(uuid.NAMESPACE_URL, '''$input'''))" 2>/dev/null && return 0

  # Fallback：用 md5 手動格式化為 UUID
  local hash
  if command -v md5 >/dev/null 2>&1; then
    hash="$(printf '%s' "$input" | md5)"
  elif command -v md5sum >/dev/null 2>&1; then
    hash="$(printf '%s' "$input" | md5sum | cut -d' ' -f1)"
  else
    echo "❌ [_qdrant_id_to_uuid] 無法產生 UUID（缺少 python3/md5/md5sum）" >&2
    return 1
  fi
  echo "${hash:0:8}-${hash:8:4}-${hash:12:4}-${hash:16:4}-${hash:20:12}"
}

########################################
# 初始化：Qdrant 連接資訊
########################################
qdrant_init_env() {
  # 環境變數：
  # QDRANT_URL 或 QDRANT_ENDPOINT: Qdrant 伺服器 URL (例如 https://xxx.gcp.cloud.qdrant.io:6333)
  # QDRANT_API_KEY: API key (Qdrant Cloud 需要)
  : "${QDRANT_URL:=${QDRANT_ENDPOINT:-http://localhost:6333}}"
  : "${QDRANT_API_KEY:=}"

  local err=0

  if [[ -z "${QDRANT_URL:-}" ]]; then
    echo "❌ [qdrant_init_env] 未設定 QDRANT_URL" >&2
    err=1
  fi

  # 指令檢查
  if declare -f require_cmd >/dev/null 2>&1; then
    require_cmd curl
    require_cmd jq
  else
    for cmd in curl jq; do
      if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ [qdrant_init_env] 需要指令：$cmd" >&2
        err=1
      fi
    done
  fi

  return "$err"
}

########################################
# Collection 管理
########################################

# qdrant_create_collection COLLECTION_NAME VECTOR_SIZE [DISTANCE]
#
# 功能：
#   - 建立新的 collection
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   VECTOR_SIZE: 向量維度 (例如 1536 for text-embedding-3-small)
#   DISTANCE: 距離計算方式 (Cosine, Euclid, Dot) 預設 Cosine
#
# 回傳值：
#   0  = 成功或已存在
#   >0 = 失敗
qdrant_create_collection() {
  local collection_name="$1"
  local vector_size="$2"
  local distance="${3:-Cosine}"

  require_cmd curl jq || return 1

  local payload
  payload="$(
    jq -n \
      --argjson size "$vector_size" \
      --arg dist "$distance" \
      '{
        vectors: {
          size: $size,
          distance: $dist
        }
      }'
  )"

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X PUT "${QDRANT_URL%/}/collections/${collection_name}"
    -H "Content-Type: application/json"
    --data-raw "$payload"
    -w '%{http_code}' -o "$tmp_body"
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [qdrant_create_collection] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_body"

  # HTTP 200 = 成功創建
  # HTTP 409 = Collection 已存在（也視為成功）
  if [[ "$http_code" == "200" ]] || [[ "$http_code" == "409" ]]; then
    return 0
  fi

  echo "❌ [qdrant_create_collection] HTTP=${http_code}" >&2
  if jq -e . >/dev/null 2>&1 <<<"$resp"; then
    echo "$resp" | jq -C '.' >&2
  else
    echo "$resp" >&2
  fi
  return 1
}

# qdrant_collection_exists COLLECTION_NAME
#
# 功能：
#   - 檢查 collection 是否存在
#
# 回傳值：
#   0  = 存在
#   1  = 不存在
qdrant_collection_exists() {
  local collection_name="$1"

  require_cmd curl jq || return 1

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X GET "${QDRANT_URL%/}/collections/${collection_name}"
    -w '%{http_code}' -o "$tmp_body"
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    rm -f "$tmp_body"
    return 1
  }

  rm -f "$tmp_body"

  if [[ "$http_code" == "200" ]]; then
    return 0
  else
    return 1
  fi
}

########################################
# Points (向量點) 操作
########################################

# qdrant_upsert_point COLLECTION_NAME POINT_ID VECTOR_JSON PAYLOAD_JSON
#
# 功能：
#   - 插入或更新單一 point
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   POINT_ID: point 的唯一 ID (字串或數字)
#   VECTOR_JSON: embedding vector (JSON array of floats)
#   PAYLOAD_JSON: metadata (JSON object)
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_upsert_point() {
  local collection_name="$1"
  local point_id="$2"
  local vector_json="$3"
  local payload_json="$4"

  require_cmd curl jq || return 1

  local max_retries=3
  local retry_delay=0.5

  local payload
  payload="$(
    printf '%s\n%s' "$vector_json" "$payload_json" | jq -sc \
      --arg id "$point_id" \
      '{
        points: [
          {
            id: $id,
            vector: .[0],
            payload: .[1]
          }
        ]
      }'
  )"

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local tmp_body http_code
    tmp_body="$(mktemp)"

    local curl_args=(
      -sS -X PUT "${QDRANT_URL%/}/collections/${collection_name}/points"
      -H "Content-Type: application/json"
      --data-raw "$payload"
      -w '%{http_code}' -o "$tmp_body"
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    # 如果 curl 成功
    if [[ $curl_exit -eq 0 ]]; then
      local resp
      resp="$(cat "$tmp_body")"
      rm -f "$tmp_body"

      if [[ "$http_code" == "200" ]]; then
        return 0
      fi

      # HTTP 錯誤（非網路錯誤），不重試
      echo "❌ [qdrant_upsert_point] HTTP=${http_code}" >&2
      if jq -e . >/dev/null 2>&1 <<<"$resp"; then
        echo "$resp" | jq -C '.' >&2
      else
        echo "$resp" >&2
      fi
      return 1
    fi

    # curl 失敗，判斷是否需要重試
    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_upsert_point] curl 失敗 (exit=$curl_exit)，重試 $attempt/$max_retries..." >&2
      sleep $retry_delay
    else
      echo "❌ [qdrant_upsert_point] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      return 1
    fi
  done

  return 1
}

# qdrant_upsert_points_batch COLLECTION_NAME POINTS_JSON
#
# 功能：
#   - 批次插入或更新 points
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   POINTS_JSON: JSON array of points，格式：
#     [
#       {"id": "id1", "vector": [...], "payload": {...}},
#       {"id": "id2", "vector": [...], "payload": {...}}
#     ]
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_upsert_points_batch() {
  local collection_name="$1"
  local points_json="$2"

  require_cmd curl jq || return 1

  # 使用臨時檔案避免命令行參數過長
  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  # 將 payload 寫入臨時檔案
  printf '%s' "$points_json" | jq -c '{points: .}' > "$tmp_payload"

  local curl_args=(
    -sS -X PUT "${QDRANT_URL%/}/collections/${collection_name}/points"
    -H "Content-Type: application/json"
    -d "@${tmp_payload}"
    -w '%{http_code}' -o "$tmp_body"
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [qdrant_upsert_points_batch] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_payload" "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_payload" "$tmp_body"

  if [[ "$http_code" == "200" ]]; then
    return 0
  fi

  echo "❌ [qdrant_upsert_points_batch] HTTP=${http_code}" >&2
  if jq -e . >/dev/null 2>&1 <<<"$resp"; then
    echo "$resp" | jq -C '.' >&2
  else
    echo "$resp" >&2
  fi
  return 1
}

# qdrant_point_exists COLLECTION_NAME POINT_ID
#
# 功能：
#   - 檢查 point 是否存在
#
# 回傳值：
#   0  = 存在
#   1  = 不存在
qdrant_point_exists() {
  local collection_name="$1"
  local point_id="$2"

  require_cmd curl jq || return 1

  local max_retries=3
  local retry_delay=0.5

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local tmp_body http_code
    tmp_body="$(mktemp)"

    local curl_args=(
      -sS -X GET "${QDRANT_URL%/}/collections/${collection_name}/points/${point_id}"
      -w '%{http_code}' -o "$tmp_body"
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    # 如果 curl 成功
    if [[ $curl_exit -eq 0 ]]; then
      local resp
      resp="$(cat "$tmp_body")"
      rm -f "$tmp_body"

      if [[ "$http_code" == "200" ]]; then
        # 檢查 result 是否為 null (point 不存在時 API 會回傳 200 但 result 為 null)
        local result
        result="$(printf '%s' "$resp" | jq -r '.result // "null"')"
        if [[ "$result" != "null" ]]; then
          return 0  # Point 存在
        fi
      fi
      return 1  # Point 不存在（HTTP 404 或 result 為 null）
    fi

    # curl 失敗，判斷是否需要重試
    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_point_exists] curl 失敗 (exit=$curl_exit)，重試 $attempt/$max_retries..." >&2
      sleep $retry_delay
    else
      echo "❌ [qdrant_point_exists] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      return 1
    fi
  done

  return 1
}

########################################
# Batch Get (檢查多個 points 是否存在)
########################################

# qdrant_get_existing_ids COLLECTION_NAME IDS_JSON
#
# 功能：
#   - 批次查詢哪些 point IDs 已存在
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   IDS_JSON: JSON array of point IDs，例如 ["id1", "id2", "id3"]
#
# stdout:
#   已存在的 IDs (JSON array)，例如 ["id1", "id3"]
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_get_existing_ids() {
  local collection_name="$1"
  local ids_json="$2"

  require_cmd curl jq || return 1

  # 使用臨時檔案避免命令行參數過長
  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  # 將 payload 寫入臨時檔案
  printf '%s' "$ids_json" | jq -c '{
    ids: .,
    with_payload: false,
    with_vector: false
  }' > "$tmp_payload"

  local curl_args=(
    -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points"
    -H "Content-Type: application/json"
    -d "@${tmp_payload}"
    -w '%{http_code}' -o "$tmp_body"
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [qdrant_get_existing_ids] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_payload" "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_payload" "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    echo "❌ [qdrant_get_existing_ids] HTTP=${http_code}" >&2
    if jq -e . >/dev/null 2>&1 <<<"$resp"; then
      echo "$resp" | jq -C '.' >&2
    else
      echo "$resp" >&2
    fi
    return 1
  fi

  # 提取已存在的 IDs
  printf '%s' "$resp" | jq -c '[.result[].id]'
}

########################################
# Search by Payload (URL 查詢)
########################################

# qdrant_exists_by_url SOURCE_URL
#
# 功能：
#   - 檢查是否存在具有特定 source_url 的 point
#
# 參數：
#   SOURCE_URL: 要查詢的 source_url
#
# 回傳值：
#   0  = 存在
#   1  = 不存在
qdrant_exists_by_url() {
  local source_url="$1"
  local collection_name="${QDRANT_COLLECTION:-disease_intel}"

  require_cmd curl jq || return 1

  local payload
  payload="$(
    jq -n \
      --arg url "$source_url" \
      '{
        filter: {
          must: [
            {
              key: "source_url",
              match: { value: $url }
            }
          ]
        },
        limit: 1,
        with_payload: false,
        with_vector: false
      }'
  )"

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points/scroll"
    -H "Content-Type: application/json"
    --data-raw "$payload"
    -w '%{http_code}' -o "$tmp_body"
  )

  if [[ -n "${QDRANT_API_KEY:-}" ]]; then
    curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    rm -f "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    return 1
  fi

  # 檢查是否有結果
  local count
  count="$(printf '%s' "$resp" | jq -r '.result.points | length')"
  if [[ "$count" -gt 0 ]]; then
    return 0  # 存在
  fi
  return 1  # 不存在
}

########################################
# Upsert from Markdown
########################################

# qdrant_upsert_from_md MD_FILE LAYER_NAME
#
# 功能：
#   - 從 Markdown 檔案讀取 metadata，生成 embedding，寫入 Qdrant
#
# 參數：
#   MD_FILE: Markdown 檔案路徑
#   LAYER_NAME: Layer 名稱
#
# 回傳值：
#   0  = 成功
#   >0 = 失敗
qdrant_upsert_from_md() {
  local md_file="$1"
  local layer_name="$2"
  local collection_name="${QDRANT_COLLECTION:-disease_intel}"

  require_cmd curl jq || return 1

  # 檢查 chatgpt_embed 是否可用
  if ! declare -f chatgpt_embed >/dev/null 2>&1; then
    echo "⚠️  [qdrant_upsert_from_md] chatgpt_embed 不可用，跳過" >&2
    return 1
  fi

  # 從 MD 檔案提取 metadata
  # 處理 YAML frontmatter 的各種引號格式：無引號、單引號、雙引號
  local title source_url date category content
  title=$(grep -m1 '^title:' "$md_file" 2>/dev/null | sed 's/^title: *//; s/^["'"'"']//; s/["'"'"']$//' || echo "")
  source_url=$(grep -m1 '^source_url:' "$md_file" 2>/dev/null | sed 's/^source_url: *//; s/^["'"'"']//; s/["'"'"']$//' || echo "")
  date=$(grep -m1 '^date:' "$md_file" 2>/dev/null | sed 's/^date: *//' || echo "")
  category=$(grep -m1 '^category:' "$md_file" 2>/dev/null | sed 's/^category: *//' || echo "")

  if [[ -z "$source_url" ]]; then
    echo "⚠️  [qdrant_upsert_from_md] 無 source_url: $md_file" >&2
    return 1
  fi

  # 提取摘要作為 embedding 文本
  content=$(awk '/^## 摘要/,/^## |^---/' "$md_file" 2>/dev/null | grep -v '^##' | grep -v '^---' | head -10 || echo "$title")
  if [[ -z "$content" ]]; then
    content="$title"
  fi

  # 生成 embedding
  local vector_json
  vector_json=$(chatgpt_embed "$title $content" 2>/dev/null) || {
    echo "⚠️  [qdrant_upsert_from_md] embedding 失敗: $md_file" >&2
    return 1
  }

  # 生成 point ID (UUID from source_url)
  local point_id
  point_id=$(_qdrant_id_to_uuid "$source_url")

  # 構建 payload
  local payload_json
  payload_json=$(jq -n \
    --arg title "$title" \
    --arg source_url "$source_url" \
    --arg date "$date" \
    --arg category "$category" \
    --arg layer "$layer_name" \
    --arg file "$md_file" \
    '{
      title: $title,
      source_url: $source_url,
      date: $date,
      category: $category,
      source_layer: $layer,
      file_path: $file,
      fetched_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
    }')

  # 寫入 Qdrant
  if qdrant_upsert_point "$collection_name" "$point_id" "$vector_json" "$payload_json"; then
    return 0
  fi

  return 1
}

########################################
# Search
########################################

# qdrant_search COLLECTION_NAME VECTOR_JSON LIMIT
#
# 功能：
#   - 搜尋最相似的 points
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   VECTOR_JSON: query vector (JSON array of floats)
#   LIMIT: 回傳結果數量
#
# stdout:
#   搜尋結果 JSON (包含 id, score, payload)
#
qdrant_search() {
  local collection_name="$1"
  local vector_json="$2"
  local limit="${3:-10}"

  require_cmd curl jq || return 1

  local max_retries=3
  local retry_delay=1

  local payload
  payload="$(
    printf '%s' "$vector_json" | jq -c \
      --argjson limit "$limit" \
      '{
        vector: .,
        limit: $limit,
        with_payload: true
      }'
  )"

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    local tmp_body http_code
    tmp_body="$(mktemp)"

    local curl_args=(
      -sS -X POST "${QDRANT_URL%/}/collections/${collection_name}/points/search"
      -H "Content-Type: application/json"
      --data-raw "$payload"
      -w '%{http_code}' -o "$tmp_body"
      --connect-timeout 10
      --max-time 30
    )

    if [[ -n "${QDRANT_API_KEY:-}" ]]; then
      curl_args+=( -H "api-key: ${QDRANT_API_KEY}" )
    fi

    http_code="$(curl "${curl_args[@]}" 2>/dev/null)"
    local curl_exit=$?

    if [[ $curl_exit -eq 0 ]]; then
      local resp
      resp="$(cat "$tmp_body")"
      rm -f "$tmp_body"

      if [[ "$http_code" == "200" ]]; then
        printf '%s\n' "$resp"
        return 0
      fi

      echo "❌ [qdrant_search] HTTP=${http_code}" >&2
      if jq -e . >/dev/null 2>&1 <<<"$resp"; then
        echo "$resp" | jq -C '.' >&2
      else
        echo "$resp" >&2
      fi
      return 1
    fi

    rm -f "$tmp_body"
    if [[ $attempt -lt $max_retries ]]; then
      echo "⚠️  [qdrant_search] curl 失敗 (exit=$curl_exit)，重試 $attempt/$max_retries..." >&2
      sleep $retry_delay
    else
      echo "❌ [qdrant_search] curl 失敗 (exit=$curl_exit)，已重試 $max_retries 次" >&2
      return 1
    fi
  done

  return 1
}

########################################
# 差異更新：只處理新增的檔案
########################################

# qdrant_filter_new_files COLLECTION_NAME FILES...
#
# 功能：
#   - 批次檢查哪些檔案尚未存在於 Qdrant
#   - 輸出需要處理的檔案路徑（每行一個）
#
# 參數：
#   COLLECTION_NAME: collection 名稱
#   FILES: 一個或多個 .md 檔案路徑
#
# stdout:
#   需要處理的檔案路徑（每行一個）
#
# 用法：
#   new_files=$(qdrant_filter_new_files "disease_intel" file1.md file2.md)
#   while IFS= read -r f; do
#     qdrant_upsert_from_md "$f" "$layer"
#   done <<< "$new_files"
#
qdrant_filter_new_files() {
  local collection_name="$1"
  shift
  local -a all_files=("$@")

  local total=${#all_files[@]}
  if [[ $total -eq 0 ]]; then
    return 0
  fi

  echo "🔍 [qdrant_filter] 檢查 $total 個檔案..." >&2

  # 收集 source_url → UUID 映射
  local -a urls=()
  local -a uuids=()
  local -a valid_files=()

  for md_file in "${all_files[@]}"; do
    local source_url
    source_url=$(grep -m1 '^source_url:' "$md_file" 2>/dev/null | sed 's/^source_url: *//; s/^["'"'"']//; s/["'"'"']$//' || echo "")
    if [[ -n "$source_url" ]]; then
      local uuid
      uuid=$(_qdrant_id_to_uuid "$source_url")
      urls+=("$source_url")
      uuids+=("$uuid")
      valid_files+=("$md_file")
    fi
  done

  local valid_count=${#valid_files[@]}
  if [[ $valid_count -eq 0 ]]; then
    echo "⚠️  [qdrant_filter] 無有效檔案" >&2
    return 0
  fi

  # 批次查詢（每次最多 100 個）
  local batch_size=100
  local -a existing_uuids=()

  for ((i=0; i<valid_count; i+=batch_size)); do
    local end=$((i + batch_size))
    [[ $end -gt $valid_count ]] && end=$valid_count

    # 構建 JSON array
    local ids_json="["
    local first=1
    for ((j=i; j<end; j++)); do
      [[ $first -eq 1 ]] && first=0 || ids_json+=","
      ids_json+="\"${uuids[j]}\""
    done
    ids_json+="]"

    # 查詢
    local result
    result=$(qdrant_get_existing_ids "$collection_name" "$ids_json" 2>/dev/null) || continue

    while IFS= read -r uuid; do
      [[ -n "$uuid" ]] && existing_uuids+=("$uuid")
    done < <(echo "$result" | jq -r '.[]' 2>/dev/null)
  done

  # 輸出不存在的檔案
  local new_count=0
  for ((i=0; i<valid_count; i++)); do
    local uuid="${uuids[i]}"
    local found=0
    for existing in "${existing_uuids[@]}"; do
      [[ "$uuid" == "$existing" ]] && { found=1; break; }
    done
    if [[ $found -eq 0 ]]; then
      echo "${valid_files[i]}"
      ((new_count++))
    fi
  done

  local skipped=$((valid_count - new_count))
  echo "✅ [qdrant_filter] 跳過 $skipped 已存在，需處理 $new_count 新檔案" >&2
}
