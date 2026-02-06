#!/usr/bin/env bash
# chatgpt.sh - 共用的 ChatGPT / OpenAI Chat Completions helper
# 注意：預期被其他 script 用 `.` source 進來
# 不在這裡 set -euo pipefail，交給呼叫端決定。

########################################
# 初始化：API key / project / base URL
########################################
chatgpt_init_env() {
  # 優先順序：
  # 1) CHATGPT_* 明確指定
  # 2) OPENAI_* 通用環境
  # 3) SORA_*（如果已經由 sora_init_env 設定過）
  : "${CHATGPT_API_KEY:=${OPENAI_API_KEY:-${SORA_API_KEY:-}}}"
  : "${CHATGPT_PROJECT_ID:=${OPENAI_PROJECT_ID:-${SORA_PROJECT_ID:-}}}"
  : "${CHATGPT_BASE_URL:=${OPENAI_BASE_URL:-${SORA_BASE_URL:-https://api.openai.com/v1}}}"

  local err=0

  if [[ -z "${CHATGPT_API_KEY:-}" ]]; then
    echo "❌ [chatgpt_init_env] 未設定 CHATGPT_API_KEY / OPENAI_API_KEY / SORA_API_KEY" >&2
    err=1
  fi

  # 指令檢查：用 core 的 require_cmd，如果有的話
  if declare -f require_cmd >/dev/null 2>&1; then
    require_cmd curl
    require_cmd jq
  else
    for cmd in curl jq; do
      if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ [chatgpt_init_env] 需要指令：$cmd" >&2
        err=1
      fi
    done
  fi

  return "$err"
}

########################################
# 低階：送一個 chat/completions，回傳完整 JSON
########################################
chatgpt_chat_raw() {
  local model="$1"
  local system_text="$2"
  local user_text="$3"
  local max_tokens="${4:-256}"
  local temperature="${5:-0.7}"

  local payload
  payload="$(
    jq -n \
      --arg model "$model" \
      --arg sys   "$system_text" \
      --arg user  "$user_text" \
      --argjson max  "$max_tokens" \
      --argjson temp "$temperature" \
      '{
        model: $model,
        messages: [
          {
            "role": "system",
            "content": [ { "type": "text", "text": $sys } ]
          },
          {
            "role": "user",
            "content": [ { "type": "text", "text": $user } ]
          }
        ],
        max_tokens: $max,
        temperature: $temp
      }'
  )"

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X POST "${CHATGPT_BASE_URL%/}/chat/completions"
    -H "Content-Type: application/json"
    -H "Authorization: Bearer ${CHATGPT_API_KEY}"
    --data-raw "$payload"
    -w '%{http_code}' -o "$tmp_body"
  )
  if [[ -n "${CHATGPT_PROJECT_ID:-}" ]]; then
    curl_args+=( -H "OpenAI-Project: ${CHATGPT_PROJECT_ID}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [chatgpt_chat_raw] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    echo "❌ [chatgpt_chat_raw] HTTP=${http_code}" >&2
    if jq -e . >/dev/null 2>&1 <<<"$resp"; then
      echo "$resp" | jq -C '.' >&2
    else
      echo "$resp" >&2
    fi
    return 1
  fi

  printf '%s\n' "$resp"
}

########################################
# 便利函式：只要 content 純文字
########################################
chatgpt_chat_text() {
  local model="$1"
  local system_text="$2"
  local user_text="$3"
  local max_tokens="${4:-256}"
  local temperature="${5:-0.7}"

  local resp
  if ! resp="$(chatgpt_chat_raw "$model" "$system_text" "$user_text" "$max_tokens" "$temperature")"; then
    return 1
  fi

  local content
  content="$(printf '%s' "$resp" | jq -r '.choices[0].message.content // empty')" || return 1
  if [[ -z "$content" || "$content" == "null" ]]; then
    echo "❌ [chatgpt_chat_text] 空回應" >&2
    return 1
  fi

  # 簡單 trim
  content="$(printf '%s' "$content" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
  printf '%s\n' "$content"
}

########################################
# Responses API with web_search tool
# 使用 OpenAI Responses API 進行網頁搜尋
########################################
chatgpt_responses_with_search() {
  local model="$1"
  local system_text="$2"
  local user_text="$3"
  local max_tokens="${4:-2000}"

  # 構建 Responses API payload
  # 注意：Responses API 使用 input 而非 messages
  local payload
  payload="$(
    jq -n \
      --arg model "$model" \
      --arg sys   "$system_text" \
      --arg user  "$user_text" \
      --argjson max  "$max_tokens" \
      '{
        model: $model,
        input: [
          {
            "role": "system",
            "content": $sys
          },
          {
            "role": "user",
            "content": $user
          }
        ],
        tools: [
          {
            "type": "web_search_preview"
          }
        ],
        tool_choice: "auto",
        max_output_tokens: $max
      }'
  )"

  local tmp_body http_code
  tmp_body="$(mktemp)"

  local curl_args=(
    -sS -X POST "${CHATGPT_BASE_URL%/}/responses"
    -H "Content-Type: application/json"
    -H "Authorization: Bearer ${CHATGPT_API_KEY}"
    --data-raw "$payload"
    -w '%{http_code}' -o "$tmp_body"
  )
  if [[ -n "${CHATGPT_PROJECT_ID:-}" ]]; then
    curl_args+=( -H "OpenAI-Project: ${CHATGPT_PROJECT_ID}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [chatgpt_responses_with_search] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    echo "❌ [chatgpt_responses_with_search] HTTP=${http_code}" >&2
    if jq -e . >/dev/null 2>&1 <<<"$resp"; then
      echo "$resp" | jq -C '.' >&2
    else
      echo "$resp" >&2
    fi
    return 1
  fi

  printf '%s\n' "$resp"
}

########################################
# 從 Responses API 回應中提取文字內容
# Responses API 回傳格式與 Chat Completions 不同
########################################
chatgpt_responses_extract_text() {
  local resp="$1"

  # Responses API 回傳結構：
  # { "output": [ { "type": "message", "role": "assistant", "content": [ { "type": "output_text", "text": "..." } ] } ] }
  local text
  text="$(printf '%s' "$resp" | jq -r '
    .output[]
    | select(.type == "message" and .role == "assistant")
    | .content[]
    | select(.type == "output_text")
    | .text
  ' | head -1)" || return 1

  if [[ -z "$text" || "$text" == "null" ]]; then
    echo "❌ [chatgpt_responses_extract_text] 無法提取文字內容" >&2
    return 1
  fi

  printf '%s\n' "$text"
}

########################################
# 從 Responses API 回應中提取網頁搜尋來源
########################################
chatgpt_responses_extract_sources() {
  local resp="$1"

  # 提取 web_search_call 的 URLs
  printf '%s' "$resp" | jq -c '
    [
      .output[]
      | select(.type == "web_search_call")
      | .action.urls[]?
    ] | unique
  ' 2>/dev/null || echo "[]"
}

########################################
# Embedding
########################################
chatgpt_embed() {
  local text="$1"
  local model="${EMBEDDING_MODEL:-text-embedding-3-small}"

  local tmp_payload tmp_body http_code
  tmp_payload="$(mktemp)"
  tmp_body="$(mktemp)"

  jq -nc --arg input "$text" --arg model "$model" \
    '{input: $input, model: $model}' > "$tmp_payload"

  local curl_args=(
    -sS -X POST "${CHATGPT_BASE_URL%/}/embeddings"
    -H "Content-Type: application/json"
    -H "Authorization: Bearer ${CHATGPT_API_KEY}"
    -d "@${tmp_payload}"
    -w '%{http_code}' -o "$tmp_body"
  )
  if [[ -n "${CHATGPT_PROJECT_ID:-}" ]]; then
    curl_args+=( -H "OpenAI-Project: ${CHATGPT_PROJECT_ID}" )
  fi

  http_code="$(curl "${curl_args[@]}" 2>/dev/null)" || {
    local rc=$?
    echo "❌ [chatgpt_embed] curl 失敗 exit=${rc}" >&2
    rm -f "$tmp_payload" "$tmp_body"
    return 1
  }

  local resp
  resp="$(cat "$tmp_body")"
  rm -f "$tmp_payload" "$tmp_body"

  if [[ "$http_code" != "200" ]]; then
    echo "❌ [chatgpt_embed] HTTP=${http_code}" >&2
    if jq -e . >/dev/null 2>&1 <<<"$resp"; then
      echo "$resp" | jq -C '.' >&2
    else
      echo "$resp" >&2
    fi
    return 1
  fi

  printf '%s' "$resp" | jq -c '.data[0].embedding'
}
