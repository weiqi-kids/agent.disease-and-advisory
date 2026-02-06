# 傳染病情報分析系統（Disease Intelligence System）— 執行規範 v1.0

## 一、系統概覽

### 1.1 系統目的

本系統是一套基於 Claude CLI 的傳染病情報分析系統，透過多角色協作完成資料擷取、萃取、報告生成與品質審核。

### 1.2 架構角色

| 角色 | 職責 | 實現方式 |
|------|------|----------|
| **Architect** | 系統巡檢、資料源探索、指揮協調 | 由 Claude CLI 頂層直接扮演（無外部腳本） |
| **Extractor** | 資料擷取（fetch）與萃取（extract） | `core/Extractor/Layers/` 下的 Layer 定義 + shell 腳本 |
| **Narrator** | 跨來源綜合分析、報告產出 | `core/Narrator/Modes/` 下的 Mode 定義 |
| **Reviewer** | 自我審核 Checklist | 內嵌於每個 Layer/Mode 的 CLAUDE.md |

### 1.3 資料流

```
外部資料源（RSS/API）
  → fetch.sh 下載原始資料 → docs/Extractor/{layer}/raw/*.jsonl
  → Claude 萃取（逐行處理）→ docs/Extractor/{layer}/{category}/*.md
  → update.sh 寫入 Qdrant + 檢查 REVIEW_NEEDED
  → Narrator Mode 讀取 Layer 資料 → docs/Narrator/{mode}/*.md
```

---

## 二、執行編排模型

### 2.1 編排原則

本系統由 **Claude CLI 全程編排**，採用 **主執行緒最小化、全面委派** 的平行執行架構：

1. **主執行緒最小化**：僅做任務分派、進度監控、結果彙整
2. **全面委派**：所有實際工作由 sonnet 子代理執行
3. **最大平行化**：無依賴關係的任務一律平行執行
4. **背景執行**：長時間任務使用 `run_in_background: true`

```
主執行緒（Opus）— 僅觀測與協調
│
├─ 階段 1：發現（輕量 Bash）
│   └─ 主執行緒直接執行：掃描 Layers/Modes 目錄
│
├─ 階段 2：Fetch（平行 sonnet）
│   └─ 同時分派 N 個 Task(Bash, sonnet) 執行所有 fetch.sh
│
├─ 階段 3：萃取（平行 sonnet）
│   └─ 同時分派 N 個 Task(general-purpose, sonnet) 處理所有 JSONL
│
├─ 階段 4：Update（平行 sonnet）
│   └─ 同時分派 N 個 Task(Bash, sonnet) 執行所有 update.sh
│
├─ 階段 5：報告（sonnet）
│   └─ Task(general-purpose, sonnet) 產出報告
│
└─ 階段 6：後處理（平行 sonnet）
    └─ 健康度更新等後處理任務
```

### 2.2 模型與子代理指派規則

| 任務類型 | 模型 | 子代理類型 | 平行策略 |
|----------|------|------------|----------|
| 目錄掃描 | - | 主執行緒直接執行 | - |
| fetch.sh | sonnet | Bash | 所有 Layer 平行 |
| JSONL 萃取 | sonnet | general-purpose | 所有條目平行（批次處理） |
| update.sh | sonnet | Bash | 所有 Layer 平行 |
| Mode 報告 | sonnet | general-purpose | 獨立 Mode 可平行 |
| 後處理 | sonnet | Bash / general-purpose | 可平行 |

> **強制規則**：所有實際工作一律使用 `sonnet`，主執行緒（opus）僅負責協調。
> **子代理規則**：需要寫入檔案的 Task 必須使用 `general-purpose`（透過 Write 工具寫檔），純腳本執行使用 `Bash`。

### 2.3 平行分派策略

#### 單一訊息多工具呼叫

平行任務必須在「同一個訊息」中發出多個 Task tool 呼叫，不可逐一發出再等待：

```
✅ 正確：一個訊息包含多個 Task 呼叫
   [Task: Layer1/fetch.sh] [Task: Layer2/fetch.sh] [Task: Layer3/fetch.sh]

❌ 錯誤：分開發送
   訊息1: [Task: Layer1/fetch.sh] → 等待完成
   訊息2: [Task: Layer2/fetch.sh] → 等待完成
   訊息3: [Task: Layer3/fetch.sh] → 等待完成
```

#### 背景執行

- 使用 `run_in_background: true` 讓任務在背景執行
- 主執行緒可繼續分派其他任務
- 透過 TaskOutput 或 Read 檢查進度

#### 批次大小

- 建議每批最多 10 個平行任務
- 超過時分批執行，但批內仍平行

### 2.4 主執行緒行為規範

#### 允許的操作

- ✅ 輕量 Bash 命令（ls, wc, cat 單行等）
- ✅ 分派 Task 子代理
- ✅ 讀取子代理輸出檔
- ✅ 與使用者對話
- ✅ 彙整結果並回報

#### 禁止的操作

- ❌ 直接執行 fetch.sh / update.sh
- ❌ 直接讀取或處理 JSONL
- ❌ 直接寫入萃取結果 .md
- ❌ 直接產出 Mode 報告
- ❌ 序列等待每個任務完成後才分派下一個

#### 進度回報格式

執行過程中，主執行緒應定期向使用者回報：

```
## 執行進度

| 階段 | 狀態 | 詳情 |
|------|------|------|
| Fetch | ✅ 完成 | 7/7 Layers |
| 萃取 | 🔄 進行中 | 45/120 條目 |
| Update | ⏳ 等待中 | - |
| 報告 | ⏳ 等待中 | - |
```

---

## 三、執行流程

使用者說「執行完整流程」或「更新資料」時，依照以下階段執行：

### 階段 1：發現（主執行緒直接執行）

主執行緒直接執行輕量 Bash 命令：

```bash
# 掃描有效 Layer（排除 .disabled）
for d in core/Extractor/Layers/*/; do
  [[ -f "$d/.disabled" ]] || echo "$d"
done

# 掃描有效 Mode（排除 .disabled）
for d in core/Narrator/Modes/*/; do
  [[ -f "$d/.disabled" ]] || echo "$d"
done
```

每個有效 Layer 目錄應包含 `fetch.sh`、`update.sh`、`CLAUDE.md`。
每個有效 Mode 目錄應包含 `CLAUDE.md`。

### 階段 2：Fetch（平行）

**在單一訊息中**同時分派所有 Layer 的 fetch：

```
Task(Bash, sonnet, run_in_background=true) → Layer1/fetch.sh
Task(Bash, sonnet, run_in_background=true) → Layer2/fetch.sh
Task(Bash, sonnet, run_in_background=true) → Layer3/fetch.sh
...（所有 Layer 同時執行）
```

- 每個 Task 執行 `core/Extractor/Layers/{layer_name}/fetch.sh`
- 使用背景執行，主執行緒等待所有 fetch 完成後進入下一階段
- 透過 TaskOutput 確認完成狀態

### 階段 3：萃取（平行）

1. **統計總行數**：主執行緒對每個 Layer 執行 `wc -l < {jsonl_file}` 取得總行數
2. **去重檢查**：檢查 `docs/Extractor/{layer_name}/` 下是否已存在相同 `source_url` 的 `.md` 檔
3. **平行分派**：**在單一訊息中**分派萃取任務

```
Task(general-purpose, sonnet) → 萃取 Layer1 第 1 行
Task(general-purpose, sonnet) → 萃取 Layer1 第 2 行
Task(general-purpose, sonnet) → 萃取 Layer2 第 1 行
...（批次平行，每批最多 10 個 Task）
```

每個萃取 Task 接收：
- 單一 JSON 字串（`sed -n '{N}p' {jsonl_file}` 取出的該行內容）
- Layer CLAUDE.md 的萃取邏輯
- core/Extractor/CLAUDE.md 的通用規則

詳見第四節 JSONL 處理規範。

### 階段 4：Update（平行）

**在單一訊息中**同時分派所有 Layer 的 update：

```
Task(Bash, sonnet, run_in_background=true) → Layer1/update.sh {md_files...}
Task(Bash, sonnet, run_in_background=true) → Layer2/update.sh {md_files...}
...（所有 Layer 同時執行）
```

- 將階段 3 產出的 `.md` 檔案路徑作為參數
- 執行 `core/Extractor/Layers/{layer_name}/update.sh` 寫入 Qdrant 並檢查 REVIEW_NEEDED

### 階段 5：報告產出

分派 Mode 報告任務：

```
Task(general-purpose, sonnet) → Mode1 報告
Task(general-purpose, sonnet) → Mode2 報告（若獨立）
...
```

每個 Mode Task：
1. 讀取該 Mode 的 `CLAUDE.md` 和 `core/Narrator/CLAUDE.md`
2. 讀取 CLAUDE.md 中宣告的來源 Layer 資料（`docs/Extractor/{layer_name}/` 下的 `.md` 檔）
3. 依照輸出框架產出報告到 `docs/Narrator/{mode_name}/`

> 若 Mode 之間有依賴關係（後一 Mode 依賴前一 Mode 輸出），則依序執行。

### 階段 6：後處理（平行）

**在單一訊息中**執行後處理任務：
- 健康度儀表板更新
- 其他清理任務

### 指定執行

使用者也可以指定執行特定 Layer 或 Mode：

- 「執行 {layer_name}」→ 只跑該 Layer 的 fetch → 萃取 → update
- 「執行 {mode_name}」→ 只跑該 Mode 的報告產出
- 「只跑 fetch」→ 平行執行所有 Layer 的 fetch.sh，不萃取
- 「只跑萃取」→ 假設 `docs/Extractor/{layer_name}/raw/` 已有 JSONL 資料，只做萃取 + update

> 指定執行時，平行化規則仍然生效。同類型任務應平行執行。

---

## 四、JSONL 處理規範

### 4.1 禁止行為

> **⛔ 禁止使用 Read 工具直接讀取 `.jsonl` 檔案**
> JSONL 檔案可能數百 KB，直接讀取會超出 token 上限。

### 4.2 正確流程

```
✅ 用 `wc -l < {jsonl_file}` 取得總行數
✅ 用 `sed -n '{N}p' {jsonl_file}` 逐行讀取（N = 1, 2, 3, ...）
✅ 每行獨立交由一個 Task 子代理處理
✅ 子代理透過 Write tool 寫出 .md 檔（不用 Bash heredoc）
```

### 4.3 子代理接收格式

每個萃取 Task 接收：
- **單一 JSON 字串**（sed 取出的該行內容）
- **Layer CLAUDE.md 的萃取邏輯**（作為 Task prompt 的一部分）
- **core/Extractor/CLAUDE.md 的通用規則**（WebFetch、REVIEW_NEEDED 等）

### 4.4 萃取前去重

在萃取前，應檢查 `docs/Extractor/{layer_name}/` 下是否已存在相同 `source_url` 或 ID 的 `.md` 檔：
- 若存在且內容相同（同一筆資料重複擷取），**跳過**該筆
- 若存在但內容不同（同一來源的更新版本），依 Layer 策略決定**覆蓋**或**保留兩版**
- 去重檢查由頂層編排邏輯執行（在分派 Task 前），不由子代理自行判斷

---

## 五、WebFetch 補充機制

### 5.1 通用規則

RSS 的 `description` 欄位資訊量有限。萃取 Task 可透過 WebFetch 工具抓取 JSON 中 `link` 欄位指向的原始公告頁面，以取得完整內容。

- 各 Layer 的 CLAUDE.md 定義該 Layer 的 WebFetch 使用策略
- WebFetch 失敗**不阻斷**萃取流程，應降級為僅基於 RSS 資料萃取
- 降級時需在 `notes` 欄位標註
- 依各 Layer 的 `[REVIEW_NEEDED]` 觸發規則判定是否標記

### 5.2 Layer CLAUDE.md 必須宣告

每個 Layer 的 CLAUDE.md 必須包含 WebFetch 策略宣告：

| WebFetch 策略 | 說明 | 適用場景 |
|---------------|------|----------|
| **必用** | 一律使用 WebFetch 抓取原始頁面 | RSS description 幾乎無資訊（如 TVN 漏洞公告） |
| **按需** | description 不足時才使用 | RSS description 有時完整有時不足（如資安新聞） |
| **不使用** | 完全基於 RSS 資料萃取 | RSS 本身已包含完整結構化資料 |

按需策略的觸發條件（由各 Layer CLAUDE.md 定義），例如：
- description 內容不足 100 字
- 缺少特定關鍵欄位（CVE、CVSS、攻擊手法等）

---

## 六、`[REVIEW_NEEDED]` 標記規範

### 6.1 統一原則

| 概念 | 含義 | 標記方式 |
|------|------|----------|
| `[REVIEW_NEEDED]` | 萃取結果**可能有誤**，需要人工確認 | 在 .md 檔開頭加上 |
| `confidence: 低` | 資料來源有**結構性限制**（如單一來源、無交叉驗證） | 在 confidence 欄位反映 |

> **兩者不等價。** 子任務不可自行擴大判定範圍。

### 6.2 Layer CLAUDE.md 必須宣告

每個 Layer 的 CLAUDE.md 必須包含明確的觸發規則表：

```markdown
### `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. {具體場景 1 — 萃取結果可能有誤}
2. {具體場景 2}
...

以下情況**不觸發** `[REVIEW_NEEDED]`：
- ❌ {場景 A — 這是結構性限制，應在 confidence 欄位反映}
- ❌ {場景 B}
...
```

### 6.3 子任務合規

- 子任務必須**嚴格遵循** Layer CLAUDE.md 定義的觸發規則
- 不可因「僅單一來源、無交叉驗證」而自行標記 REVIEW_NEEDED
- 不可因「欄位為空」（資料來源本身不提供該欄位）而標記 REVIEW_NEEDED

---

## 七、目錄結構

### 7.1 完整結構

```
{project_root}/
├── CLAUDE.md                              # 執行入口（Claude CLI 自動載入）
├── README.md                              # 專案說明 + 健康度儀表板
├── .env                                   # 環境設定（不入版控）
├── .gitignore
│
├── core/
│   ├── CLAUDE.md                          # 系統維護指令（維護時載入）
│   ├── Architect/
│   │   └── CLAUDE.md                      # Architect 角色說明（由 Claude CLI 直接扮演）
│   ├── Extractor/
│   │   ├── CLAUDE.md                      # Extractor 角色說明 + 通用規則
│   │   └── Layers/
│   │       └── {layer_name}/
│   │           ├── CLAUDE.md              # Layer 定義 + 萃取邏輯 + 審核規則
│   │           ├── fetch.sh               # 資料擷取（輸出到 docs/Extractor/{layer_name}/raw/）
│   │           ├── update.sh              # Qdrant 更新 + REVIEW_NEEDED 檢查
│   │           └── .disabled              # 存在時跳過此 Layer
│   └── Narrator/
│       ├── CLAUDE.md                      # Narrator 角色說明
│       └── Modes/
│           └── {mode_name}/
│               ├── CLAUDE.md              # Mode 定義 + 輸出框架 + 審核規則
│               └── .disabled              # 存在時跳過此 Mode
│
├── lib/
│   ├── args.sh                            # 參數解析工具
│   ├── core.sh                            # 核心工具函式
│   ├── time.sh                            # 時間/日期工具
│   ├── rss.sh                             # RSS 擷取與解析（fetch.sh 的核心依賴）
│   ├── chatgpt.sh                         # OpenAI embedding 呼叫（Qdrant 寫入的核心依賴）
│   └── qdrant.sh                          # Qdrant 向量資料庫操作
│
├── docs/
│   ├── explored.md                        # 資料源探索紀錄
│   ├── prompt-v2.md                       # 本文件
│   ├── Extractor/
│   │   └── {layer_name}/
│   │       ├── raw/                       # 原始資料（.gitignore）
│   │       │   ├── rss-*.xml              # 下載的 RSS XML
│   │       │   ├── rss-*.jsonl            # 轉換後的 JSONL
│   │       │   └── .last_fetch            # 最後擷取時間戳
│   │       └── {category}/               # 萃取結果（.md 檔）
│   └── Narrator/
│       └── {mode_name}/
│           └── {報告檔名}.md              # 報告文件
│
└── .github/
    └── workflows/
        └── build-index.yml                # docs/ 下 .md 變動時自動重建 index.json
```

### 7.2 lib/ 說明

| 檔案 | 用途 | 主要依賴者 |
|------|------|------------|
| `args.sh` | 命令列參數解析 | 所有 shell 腳本 |
| `core.sh` | 通用工具函式（路徑、日誌等） | 所有 shell 腳本 |
| `time.sh` | 時間與日期計算 | fetch.sh、update.sh |
| `rss.sh` | RSS 下載（`rss_fetch`）、XML 轉 JSONL（`rss_extract_items_jsonl`） | fetch.sh（RSS 類型） |
| `api.sh` | JSON API 擷取（`api_fetch_odata`、`api_fetch_json`） | fetch.sh（API 類型） |
| `chatgpt.sh` | OpenAI API 呼叫（text-embedding-3-small） | update.sh（透過 qdrant.sh） |
| `qdrant.sh` | Qdrant 向量資料庫 CRUD、去重（by source_url） | update.sh |

---

## 八、Layer 建立規範

### 8.1 Layer 定義表

新增 Layer 時必須確認以下每一欄：

| 項目 | 說明 |
|------|------|
| **Layer name** | 中英文名稱 |
| **Engineering function** | 這個 Layer 的工程職責 |
| **Collectable data** | 可收集的資料類型與來源 |
| **Automation level** | 自動化程度百分比 + 說明 |
| **Output value** | 產出的價值 |
| **Risk type** | 主要風險 |
| **Reviewer persona** | 從審核人設池中選擇 |
| **Category enum** | 固定分類清單（英文 key + 中文 + 判定條件） |
| **WebFetch 策略** | 必用 / 按需（含觸發條件） / 不使用 |

### 8.2 Layer CLAUDE.md 必備內容

每個 Layer 的 CLAUDE.md 必須包含：

1. **Layer 定義表**（見 8.1）
2. **執行指令** — 萃取邏輯與輸出格式
3. **分類規則（enum）** — 固定值清單 + 判定條件
   > **嚴格限制：category 只能使用定義的英文值，不可自行新增。** 需要新增 category 時必須與使用者確認後寫入 CLAUDE.md。
4. **WebFetch 補充規則** — 策略宣告 + 降級處理
5. **`[REVIEW_NEEDED]` 觸發規則** — 必須標記的場景 + 不觸發的場景
6. **輸出格式** — Markdown 模板
7. **自我審核 Checklist** — 輸出前必須逐項確認

### 8.3 fetch.sh 模板

```bash
#!/bin/bash
# {layer_name} 資料擷取腳本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

LAYER_NAME="{layer_name}"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# === 資料擷取邏輯 ===
# 1. rss_fetch 下載 XML 到 $RAW_DIR/
# 2. rss_extract_items_jsonl 轉換為 JSONL

echo "Fetch completed: $LAYER_NAME"
```

### 8.4 update.sh 模板

```bash
#!/bin/bash
# {layer_name} 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="{layer_name}"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in {category_enum_values}; do
  mkdir -p "$DOCS_DIR/$category"
done

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]]; then
  qdrant_init_env || echo "Qdrant 連線失敗" >&2
fi

# === REVIEW_NEEDED 檢查 ===
REVIEW_FILES=""
for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo "需要審核：" && echo -e "$REVIEW_FILES"
  command -v gh >/dev/null 2>&1 && gh issue create \
    --title "[Extractor] $LAYER_NAME - 需要人工審核" \
    --label "review-needed" \
    --body "偵測到 [REVIEW_NEEDED] 標記" 2>/dev/null || true
fi

echo "Update completed: $LAYER_NAME"
```

---

## 九、Mode 建立規範

### 9.1 Mode 定義表

新增 Mode 時必須確認以下每一欄：

| 項目 | 說明 |
|------|------|
| **Mode name** | 中英文名稱 |
| **Purpose and audience** | 報告目的與目標受眾 |
| **Source layers** | 讀取哪些 Layer 的資料 |
| **Automation ratio** | 自動化比例 + 說明 |
| **Content risk** | 內容風險 |
| **Reviewer persona** | 從審核人設池中選擇 |

### 9.2 Mode CLAUDE.md 必備內容

每個 Mode 的 CLAUDE.md 必須包含：

1. **Mode 定義表**（見 9.1）
2. **資料來源定義** — 從 Qdrant / docs / 本次執行讀取的資料
3. **輸出框架** — 報告結構
4. **免責聲明** — 必須包含的法律與使用限制說明
5. **輸出位置** — 檔案路徑（通常為 `{YYYY}-W{WW}-{mode_name}.md`）
6. **自我審核 Checklist** — 發布前必須逐項確認

---

## 十、系統維護操作

### 10.1 Layer 管理

在 `core/` 目錄下操作，Claude CLI 會載入 `core/CLAUDE.md`。

#### 新增 Layer

使用者說：「新增一個 {名稱} Layer，資料來源是 {URL}，類型是 {RSS/API/...}」

執行流程：
1. 與使用者確認 Layer 定義表（見 8.1）
2. 確認 category enum 清單（嚴格限定，不可開放式）
3. 確認 WebFetch 策略
4. 確認 `[REVIEW_NEEDED]` 觸發規則
5. 建立目錄 `core/Extractor/Layers/{layer_name}/`
6. 產生 `fetch.sh`、`update.sh`、`CLAUDE.md`（依模板）
7. 建立 `docs/Extractor/{layer_name}/` 及 category 子目錄
8. 更新 `docs/explored.md`「已採用」表格
9. 告知使用者需要在 `.env` 補充的設定（若有）

#### 修改 Layer

1. 讀取 `core/Extractor/Layers/{layer_name}/CLAUDE.md` 確認現況
2. 與使用者確認修改內容
3. 修改對應檔案
4. 若 category enum 有變動，確認不會影響既有 docs 分類
5. 列出影響範圍（哪些 Mode 會受影響）

#### 刪除 / 暫停 Layer

- 刪除前列出依賴此 Layer 的所有 Mode，警告影響範圍
- 暫停：在 Layer 目錄建立 `.disabled` 標記檔
- 執行流程會自動跳過帶有 `.disabled` 的 Layer

### 10.2 Mode 管理

與 Layer 管理邏輯類似，在 `core/Narrator/Modes/` 下操作。

### 10.3 資料源管理

使用者說：「我找到一個新的資料源 {URL}」

執行流程：
1. 測試連線（curl 確認可達）
2. 若為 RSS，驗證格式並顯示前 5 筆標題
3. 更新 `docs/explored.md`「評估中」表格
4. 詢問使用者要建立新 Layer 還是加入現有 Layer

### 10.4 docs/explored.md 格式

```markdown
## 已採用
| 資料源 | 類型 | 對應 Layer | 採用日期 | 備註 |

## 評估中
| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 下次評估 |

## 已排除
| 資料源 | 類型 | 排除原因 | 排除日期 | 重新評估時間 |
```

> **v1 修正**：「評估中」表格新增 URL 和語言欄位，便於批次評估。

---

## 十一、系統規範

### 11.1 審核人設池

| 審核人設 | 關注重點 |
|----------|----------|
| 資料可信度審核員 | 來源是否一手、是否可驗證 |
| 幻覺風險審核員 | AI 是否產生無中生有的內容 |
| 領域保守審核員 | 是否符合該領域的專業標準 |
| 邏輯一致性審核員 | 前後陳述是否矛盾 |
| 法規與責任審核員 | 是否有法律風險 |
| 使用者誤導風險審核員 | 是否可能造成誤解 |
| 自動化邊界審核員 | 是否超出適合自動化的範圍 |

### 11.2 Qdrant 設定

- Collection 和 向量維度設定在 .env
- 距離：Cosine
- Payload 必要欄位：`source_url`、`fetched_at`、`original_content`、`source_layer`、`title`、`date`、`category`、`severity`
- 去重機制：以 `source_url` 為主鍵，避免重複寫入

### 11.3 禁止行為

1. 不可產出無法驗證的「專業外觀」聲明 — 所有聲明必須有來源
2. 不可跳過審核層 — 每個輸出必須經過自我審核 checklist
3. 不可混淆推測與事實 — 推測必須明確標註
4. 不可將高風險領域標記為全自動 — 涉及法律、財務建議等必須有人工介入
5. 不可自行新增 category enum 值 — 必須與使用者確認後寫入 CLAUDE.md
6. 不可使用 Read 工具直接讀取 `.jsonl` 檔案 — 一律透過 `sed -n '{N}p'` 逐行讀取
7. 不可自行擴大 `[REVIEW_NEEDED]` 判定範圍 — 嚴格遵循各 Layer CLAUDE.md 的觸發規則

### 11.4 GitHub Actions

僅保留一個 workflow：
- `build-index.yml`：docs/ 下的 .md 變動時自動重建 `index.json`
- `index.json` 不由 update.sh 或萃取流程產生

> **v1 修正**：移除了 `explore-source.yml`、`patrol.yml`、`update-health.yml` 的規範。這些功能由 Claude CLI 手動執行即可。

---

## 十二、環境設定

執行前需確認 `.env` 包含以下設定：

```
QDRANT_URL=...
QDRANT_API_KEY=...
QDRANT_COLLECTION=...
EMBEDDING_MODEL=...
EMBEDDING_DIMENSION=...
OPENAI_API_KEY=sk-...
```

---

## 十三、輸出規則

- Layer 萃取的 `.md` 檔必須遵循該 Layer CLAUDE.md 定義的格式
- Mode 報告的 `.md` 檔必須遵循該 Mode CLAUDE.md 定義的框架
- 所有輸出必須通過各自的「自我審核 Checklist」
- 未通過審核的輸出必須在開頭加上 `[REVIEW_NEEDED]`
- `index.json` 由 GitHub Actions 自動產生，不在此流程中處理

---

## 十四、互動規則

完成執行後，簡要回報：

1. 各 Layer 擷取與萃取結果（筆數、有無 REVIEW_NEEDED）
2. 各 Mode 報告產出狀態
3. 是否有錯誤或需要人工介入的項目

> **v1 修正**：移除了「這是用於內容引擎、業務系統、還是內部工具？」等通用模板問題。本系統專為資安情報分析設計，每次執行不需重新詢問用途。

---

## 十五、健康度儀表板

README.md 中的系統健康度表格由頂層 Claude CLI 在「執行完整流程」後更新：

| Layer | 最後更新 | 資料筆數 | 狀態 |
|-------|----------|----------|------|
| {Layer 名稱} | {YYYY-MM-DD} | {N} | {✅/⚠️/❌} |

| Mode | 最後產出 | 狀態 |
|------|----------|------|
| {Mode 名稱} | {YYYY-MM-DD} | {✅/⚠️/❌} |

健康度判定規則：
- ✅ 正常：最後更新在預期週期內
- ⚠️ 需關注：超過預期週期但未超過 2 倍
- ❌ 異常：超過預期週期 2 倍以上

---

## 十六、技術備忘錄

### 16.1 Shell 腳本相容性

> **⚠️ macOS 預設 Bash 版本為 3.2，不支援 Bash 4.0+ 功能**

#### 禁止使用的語法

```bash
# ❌ 禁止：Associative arrays（需要 Bash 4.0+）
declare -A FEEDS=(
    ["key1"]="value1"
    ["key2"]="value2"
)
for key in "${!FEEDS[@]}"; do
    value="${FEEDS[$key]}"
done
```

#### 正確的替代方案

```bash
# ✅ 正確：使用 parallel arrays（Bash 3.2 相容）
FEED_NAMES=(key1 key2)
FEED_URLS=(
    "value1"
    "value2"
)
for i in "${!FEED_NAMES[@]}"; do
    name="${FEED_NAMES[$i]}"
    url="${FEED_URLS[$i]}"
done
```

#### 其他 Bash 4.0+ 限制功能（避免使用）

- `declare -A`（associative arrays）
- `${var,,}`（lowercase）→ 改用 `tr '[:upper:]' '[:lower:]'`
- `${var^^}`（uppercase）→ 改用 `tr '[:lower:]' '[:upper:]'`
- `|&`（pipe stderr）→ 改用 `2>&1 |`
- `coproc`（coprocesses）

#### 字串比較運算子

Bash **不支援** `>=` 和 `<=` 字串比較運算子：

```bash
# ❌ 錯誤：Bash 不支援 >= 和 <=
if [[ "$week" >= "$from_week" && "$week" <= "$to_week" ]]; then

# ✅ 正確：使用 < 和 > 的否定形式
if [[ ! "$week" < "$from_week" && ! "$week" > "$to_week" ]]; then

# ✅ 或者：使用 sort 比較
if [[ $(printf '%s\n' "$from_week" "$week" | sort | head -1) == "$from_week" ]]; then
```

> **注意**：`<` 和 `>` 在 `[[ ]]` 中是字典序比較，這對 `YYYY-WWW` 格式有效。

### 16.2 已知資料源 URL

以下為經過驗證的官方資料源 URL：

| Layer | 資料源 | 正確 URL | 備註 |
|-------|--------|----------|------|
| us_cdc_han | CDC HAN RSS | `https://tools.cdc.gov/api/v2/resources/media/413690.rss` | 舊 URL `emergency.cdc.gov/han/HAN_rss.asp` 已失效 |
| us_cdc_mmwr | CDC MMWR RSS | `https://tools.cdc.gov/api/v2/resources/media/342778.rss` | - |
| who_disease_outbreak_news | WHO API | `https://www.who.int/api/news/diseaseoutbreaknews` | OData JSON API |

### 16.3 常見問題

#### RSS Feed 回傳 0 筆資料

某些 RSS feed（如 CDC HAN）只在有緊急事件時才有內容。這是正常現象，不是錯誤：
- CDC HAN：僅在公衛緊急事件時發布警報
- 驗證方式：檢查 RSS 是否有效（包含 `<channel>` 結構），而非依據 item 數量

#### WebFetch 失敗

- 不應阻斷萃取流程
- 應在 `notes` 欄位標註降級原因
- 依各 Layer 的 `[REVIEW_NEEDED]` 規則判定是否標記

### 16.4 新增 Layer 檢查清單

建立新 Layer 後，執行以下驗證：

```bash
# 1. 語法檢查
bash -n core/Extractor/Layers/{layer}/fetch.sh
bash -n core/Extractor/Layers/{layer}/update.sh

# 2. 執行 fetch
bash core/Extractor/Layers/{layer}/fetch.sh

# 3. 檢查輸出
wc -l docs/Extractor/{layer}/raw/*.jsonl
head -1 docs/Extractor/{layer}/raw/*.jsonl | jq .

# 4. 檢查目錄結構
ls -la docs/Extractor/{layer}/
```

### 16.5 lib/ 腳本測試規範

新增或修改 `lib/*.sh` 時，必須遵循以下測試流程：

#### 語法檢查

```bash
# 先做語法檢查，避免載入時錯誤
bash -n lib/{script}.sh
```

#### 載入測試

```bash
# ⚠️ 使用絕對路徑或 bash -c 包裝，避免路徑解析問題
bash -c 'source /full/path/to/lib/{script}.sh && {function_name} {args}'

# ❌ 可能失敗：相對路徑在某些 shell 環境下解析不正確
source lib/{script}.sh
```

#### 為什麼需要絕對路徑？

`BASH_SOURCE[0]` 的行為在不同情境下不同：
- 直接執行腳本：返回腳本路徑
- 透過 `source` 載入：返回被 source 的腳本路徑
- Claude CLI 的 Bash tool：工作目錄可能與預期不同

因此 lib 腳本內部使用 `$(dirname "${BASH_SOURCE[0]}")` 來定位自己，但測試時仍建議用絕對路徑確保一致性。

---

End of CLAUDE.md
