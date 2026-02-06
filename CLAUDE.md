# 傳染病情報分析系統（Disease Intelligence System）

## 快速指令

| 指令 | 說明 |
|------|------|
| **「執行完整流程」** | 執行所有 Layer 的 fetch → 萃取 → update → 推送 GitHub |
| **「執行 {layer_name}」** | 只執行指定 Layer 的 fetch → 萃取 → update |
| **「只跑 fetch」** | 只執行所有 Layer 的 fetch.sh，不萃取 |
| **「只跑萃取」** | 假設 raw/ 已有資料，只做萃取 + update |
| **「產出報告」** | 只執行 Narrator Mode 產出報告 |

---

## 執行架構

```
主執行緒 — 僅協調，不做實際工作
│
├─ Task(Bash, sonnet) — 掃描 Layers
│
├─ Task(Bash, sonnet, run_in_background=true) × 7
│   └─ 背景平行執行 fetch.sh
│
├─ Task(general-purpose, sonnet) × N
│   └─ 平行萃取 JSONL 各行
│
├─ Task(Bash, sonnet, run_in_background=true) × 7
│   └─ 背景平行執行 update.sh
│
├─ Task(general-purpose, opus) ← 報告需要 opus
│   └─ 產出週報（跨來源綜合分析）
│
└─ Task(Bash, sonnet) — 健康度更新 + git push
```

**模型分配原則：**

| 任務類型 | 模型 | 原因 |
|----------|------|------|
| fetch / update / 萃取 | **sonnet** | 單一來源處理，不需複雜推理 |
| 報告產出 | **opus** | 跨來源綜合、趨勢判斷、歷史比較 |

**執行原則：**
- 主執行緒只做協調（分派 Task、接收結果、回報進度）
- 使用 `run_in_background: true` 讓 fetch/update 背景平行執行
- 同類型任務在**單一訊息**中平行分派

---

## 執行完整流程

當使用者說「執行完整流程」時，依序執行以下階段：

### 階段 1：掃描 Layers（sonnet）

```
Task(Bash, sonnet) → 掃描 Layers + 統計 JSONL 行數
```

```bash
# 找出所有啟用的 Layer
for d in core/Extractor/Layers/*/; do
  [[ -f "$d/.disabled" ]] || basename "$d"
done

# 統計各 Layer 的 JSONL 行數
wc -l docs/Extractor/*/raw/*.jsonl
```

### 階段 2：平行 Fetch（背景 sonnet）

**在單一訊息中**分派所有 fetch 任務，使用背景執行：

```
Task(Bash, sonnet, run_in_background=true) → fetch.sh Layer1
Task(Bash, sonnet, run_in_background=true) → fetch.sh Layer2
Task(Bash, sonnet, run_in_background=true) → fetch.sh Layer3
...（7 個 Layer 同時背景執行）
```

等待方式：使用 `TaskOutput` 確認所有背景任務完成。

產出：`docs/Extractor/{layer}/raw/*.jsonl`

### 階段 3：萃取（平行 sonnet）

1. **統計**：對每個 Layer 執行 `wc -l < *.jsonl`
2. **去重**：檢查 `source_url` 是否已存在於 `docs/Extractor/{layer}/`
3. **分派**：每 10 筆為一批，平行分派萃取任務

```
Task(general-purpose, sonnet) → 萃取 Layer1 行 1-10
Task(general-purpose, sonnet) → 萃取 Layer2 行 1-10
...（批次平行）
```

萃取 Task 接收：
- JSON 內容（`sed -n '{N}p' file.jsonl`）
- Layer CLAUDE.md 萃取邏輯
- core/Extractor/CLAUDE.md 通用規則

產出：`docs/Extractor/{layer}/{category}/*.md`

### 階段 4：平行 Update（背景 sonnet）

**在單一訊息中**分派所有 update 任務：

```
Task(Bash, sonnet, run_in_background=true) → update.sh Layer1
Task(Bash, sonnet, run_in_background=true) → update.sh Layer2
...（所有 Layer 同時背景執行）
```

update.sh 職責：
- 寫入 Qdrant（向量化）
- 檢查 `[REVIEW_NEEDED]` 標記

### 階段 5：產出報告（opus）

> **必須使用 opus** — 報告需要跨來源綜合分析、趨勢判斷、歷史比較

```
Task(general-purpose, opus) → 讀取 Mode CLAUDE.md，產出報告
```

報告任務需要：
- 讀取多個 Layer 的萃取結果
- 讀取上一期報告做比較
- 判定優先級和趨勢變化

產出：`docs/Narrator/{mode}/*.md`

### 階段 6：更新健康度 + 推送 GitHub（sonnet）

```
Task(Bash, sonnet) → 更新健康度 + git commit + push
```

```bash
# 更新 README.md 健康度表格
# ...

# 檢查是否有變更
git status --porcelain

# 若有變更，提交並推送
git add docs/ README.md
git commit -m "data: update $(date +%Y-%m-%d) - {摘要}"
git push origin main
```

Commit message 格式：
```
data: update YYYY-MM-DD - N new items across M layers

Layers updated:
- layer1: +X items
- layer2: +Y items

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### 階段 7：GitHub Actions 自動化（推送後自動執行）

> **此階段由 GitHub Actions 自動執行，不需要 Claude CLI 操作。**

推送到 GitHub 後，以下流程自動觸發：

```
git push
    ↓
GitHub Actions: pages-build-deployment
    ↓ (部署完成後)
GitHub Actions: Check and Fix Links
    ├─ lychee 掃描所有連結
    ├─ 發現錯誤 → scripts/fix-broken-links.sh 自動修復
    ├─ 可修復 → commit + push（觸發重新部署）
    └─ 無法修復 → 建立 Issue（標記 needs-manual-fix）
```

**相關檔案：**
- `.github/workflows/check-links.yml` — 連結檢查 workflow
- `.lychee.toml` — lychee 設定（排除規則）
- `scripts/fix-broken-links.sh` — 自動修復腳本

**可自動修復的問題：**
- 連結尾部斜線（`article/` → `article`）
- index.md 表格連結格式錯誤

**無法自動修復（會開 Issue）：**
- 外部網站失效
- 檔案真的不存在

---

## 進度回報格式

執行過程中定期回報：

```
## 執行進度

| 階段 | 模型 | 狀態 | 詳情 |
|------|------|------|------|
| 掃描 | sonnet | ✅ 完成 | 7 Layers |
| Fetch | sonnet | ✅ 完成 | 7/7 Layers |
| 萃取 | sonnet | 🔄 進行中 | 45/120 條目 |
| Update | sonnet | ⏳ 等待中 | - |
| 報告 | opus | ⏳ 等待中 | - |
| GitHub | sonnet | ⏳ 等待中 | - |
| 連結檢查 | GitHub Actions | ⏳ 自動 | 推送後觸發 |
```

完成後回報：
1. 各 Layer 擷取筆數
2. 新增的萃取結果數量
3. 有無 `[REVIEW_NEEDED]` 需要人工介入
4. GitHub commit URL

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

### 背景執行與平行化

```
✅ 正確：單一訊息 + 背景執行
   [Task: Layer1, run_in_background=true]
   [Task: Layer2, run_in_background=true]
   [Task: Layer3, run_in_background=true]
   → 三個任務同時背景執行

❌ 錯誤：逐一發送等待
   訊息1: [Task: Layer1] → 等待完成
   訊息2: [Task: Layer2] → 等待完成
```

### JSONL 處理

> **⛔ 禁止使用 Read 工具直接讀取 `.jsonl` 檔案**

```bash
wc -l < file.jsonl           # 取得行數
sed -n '1p' file.jsonl       # 讀取第 1 行
sed -n '5,10p' file.jsonl    # 讀取第 5-10 行
```

### [REVIEW_NEEDED] 標記

- 各 Layer 的 `CLAUDE.md` 定義具體觸發規則
- 子代理必須嚴格遵循，不可自行擴大判定範圍
- `[REVIEW_NEEDED]` ≠ `confidence: 低`

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
