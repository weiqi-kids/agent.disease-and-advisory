# 傳染病情報分析系統（Disease Intelligence System）

## 快速指令

| 指令 | 說明 |
|------|------|
| **「執行完整流程」** | 執行所有 Layer 的 fetch → 萃取 → update，然後產出報告 |
| **「執行 {layer_name}」** | 只執行指定 Layer 的 fetch → 萃取 → update |
| **「只跑 fetch」** | 只執行所有 Layer 的 fetch.sh，不萃取 |
| **「只跑萃取」** | 假設 raw/ 已有資料，只做萃取 + update |
| **「產出報告」** | 只執行 Narrator Mode 產出報告 |

---

## 執行完整流程

當使用者說「執行完整流程」時，依序執行以下階段：

### 階段 1：掃描 Layers

```bash
# 找出所有啟用的 Layer（沒有 .disabled 檔案）
for d in core/Extractor/Layers/*/; do
  [[ -f "$d/.disabled" ]] || basename "$d"
done
```

### 階段 2：平行 Fetch

**在單一訊息中**同時分派所有 Layer 的 fetch：

```
Task(Bash, sonnet) → bash core/Extractor/Layers/who_disease_outbreak_news/fetch.sh
Task(Bash, sonnet) → bash core/Extractor/Layers/us_cdc_han/fetch.sh
Task(Bash, sonnet) → bash core/Extractor/Layers/us_cdc_mmwr/fetch.sh
...（所有 Layer 平行執行）
```

產出位置：`docs/Extractor/{layer}/raw/*.jsonl`

### 階段 3：萃取

對每個 Layer 的 JSONL 逐行萃取：

1. **取得行數**：`wc -l < docs/Extractor/{layer}/raw/*.jsonl`
2. **逐行讀取**：`sed -n '{N}p' {jsonl_file}`
3. **去重檢查**：檢查該 `source_url` 是否已存在
4. **分派萃取**：每行交由一個 Task(general-purpose, sonnet) 處理

萃取 Task 需讀取：
- 該行 JSON 內容
- `core/Extractor/Layers/{layer}/CLAUDE.md`（萃取邏輯）
- `core/Extractor/CLAUDE.md`（通用規則）

產出位置：`docs/Extractor/{layer}/{category}/*.md`

### 階段 4：平行 Update

**在單一訊息中**同時分派所有 Layer 的 update：

```
Task(Bash, sonnet) → bash core/Extractor/Layers/who_disease_outbreak_news/update.sh
Task(Bash, sonnet) → bash core/Extractor/Layers/us_cdc_han/update.sh
...（所有 Layer 平行執行）
```

update.sh 職責：
- 將 .md 檔寫入 Qdrant（向量化搜尋）
- 檢查 `[REVIEW_NEEDED]` 標記

### 階段 5：產出報告（若有 Mode）

```
Task(general-purpose, sonnet) → 讀取 Mode CLAUDE.md，產出報告
```

產出位置：`docs/Narrator/{mode}/*.md`

### 階段 6：更新健康度

更新 README.md 中的健康度儀表板。

---

## 進度回報格式

執行過程中定期回報：

```
## 執行進度

| 階段 | 狀態 | 詳情 |
|------|------|------|
| Fetch | ✅ 完成 | 7/7 Layers |
| 萃取 | 🔄 進行中 | 45/120 條目 |
| Update | ⏳ 等待中 | - |
| 報告 | ⏳ 等待中 | - |
```

完成後回報：
1. 各 Layer 擷取筆數
2. 新增的萃取結果
3. 有無 `[REVIEW_NEEDED]` 需要人工介入

---

## 現有 Layers

| Layer | 資料來源 | 說明 |
|-------|----------|------|
| `who_disease_outbreak_news` | WHO API | 世衛組織疾病爆發新聞 |
| `us_cdc_han` | CDC RSS | 美國 CDC 健康警報網絡 |
| `us_cdc_mmwr` | CDC RSS | 美國 CDC 發病率與死亡率週報 |
| `us_travel_health_notices` | CDC RSS | 美國 CDC 旅遊健康通知 |
| `ecdc_cdtr` | ECDC RSS | 歐洲 CDTR 週報 |
| `uk_ukhsa_updates` | UKHSA RSS | 英國健康安全局更新 |
| `tw_cdc_alerts` | Taiwan CDC | 台灣 CDC 警報 |

---

## 關鍵規則

### JSONL 處理

> **⛔ 禁止使用 Read 工具直接讀取 `.jsonl` 檔案**

正確做法：
```bash
wc -l < file.jsonl           # 取得行數
sed -n '1p' file.jsonl       # 讀取第 1 行
sed -n '2p' file.jsonl       # 讀取第 2 行
```

### 平行執行

同類型任務必須在**單一訊息**中發出多個 Task：

```
✅ 正確：一個訊息包含多個 Task
   [Task: Layer1/fetch.sh] [Task: Layer2/fetch.sh] [Task: Layer3/fetch.sh]

❌ 錯誤：逐一發送等待
   訊息1: [Task: Layer1] → 等待 → 訊息2: [Task: Layer2] → 等待
```

### [REVIEW_NEEDED] 標記

- 各 Layer 的 `CLAUDE.md` 定義具體觸發規則
- 子代理必須嚴格遵循，不可自行擴大判定範圍
- `[REVIEW_NEEDED]` ≠ `confidence: 低`（前者是萃取可能有誤，後者是來源結構限制）

### WebFetch

- 各 Layer 定義是否使用 WebFetch 補充
- WebFetch 失敗**不阻斷**萃取，降級處理並標註

---

## 目錄結構

```
{project_root}/
├── CLAUDE.md                    # 本文件 — 執行入口
├── README.md                    # 專案說明 + 健康度儀表板
├── .env                         # 環境設定（不入版控）
│
├── core/
│   ├── CLAUDE.md                # 系統維護指令
│   ├── Extractor/
│   │   ├── CLAUDE.md            # Extractor 通用規則
│   │   └── Layers/{layer}/
│   │       ├── CLAUDE.md        # Layer 萃取邏輯
│   │       ├── fetch.sh         # 資料擷取腳本
│   │       └── update.sh        # Qdrant 更新腳本
│   └── Narrator/
│       ├── CLAUDE.md            # Narrator 通用規則
│       └── Modes/{mode}/
│           └── CLAUDE.md        # Mode 報告框架
│
├── lib/                         # 共用 shell 函式庫
│   ├── rss.sh                   # RSS 擷取與解析
│   ├── chatgpt.sh               # OpenAI embedding
│   └── qdrant.sh                # Qdrant 向量資料庫
│
└── docs/
    ├── Extractor/{layer}/
    │   ├── raw/                 # 原始資料（.gitignore）
    │   └── {category}/*.md      # 萃取結果
    └── Narrator/{mode}/*.md     # 報告文件
```

---

## 環境設定

執行前確認 `.env` 包含：

```bash
QDRANT_URL=https://your-instance.qdrant.io:6333
QDRANT_API_KEY=
QDRANT_COLLECTION=disease-intel
OPENAI_API_KEY=sk-...
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIMENSION=1536
```

---

## 技術備忘

### Bash 3.2 相容性（macOS）

```bash
# ❌ 禁止：Bash 4.0+ 功能
declare -A map=()           # associative arrays
${var,,}                    # lowercase

# ✅ 使用替代方案
NAMES=(a b c)               # parallel arrays
URLS=(x y z)
echo "$var" | tr '[:upper:]' '[:lower:]'
```

### 已知資料源 URL

| Layer | 正確 URL |
|-------|----------|
| us_cdc_han | `https://tools.cdc.gov/api/v2/resources/media/413690.rss` |
| us_cdc_mmwr | `https://tools.cdc.gov/api/v2/resources/media/342778.rss` |
| who_disease_outbreak_news | `https://www.who.int/api/news/diseaseoutbreaknews` |

### 0 筆資料是正常的

某些 RSS（如 CDC HAN）只在有緊急事件時才有內容。驗證 RSS 是否有效應檢查 `<channel>` 結構，而非 item 數量。

---

## 系統維護

Layer 或 Mode 的新增、修改、刪除，請在 `core/` 目錄下操作。
Claude CLI 會載入 `core/CLAUDE.md` 並依照其中的維護指令執行。

常用維護指令：
- 「新增一個 {名稱} Layer，資料來源是 {URL}」
- 「暫停 {layer_name}」→ 建立 `.disabled` 檔
- 「啟用 {layer_name}」→ 移除 `.disabled` 檔

---

End of CLAUDE.md
