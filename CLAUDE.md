# EpiAlert 疫情快訊

## 重要規則

> **推送後必須確認網站更新**：每次 `git push` 後，必須等待 GitHub Pages 部署完成，並實際檢查網站內容已更新，才能告知使用者「完成」。不可只推送就說完成。

---

## 預設授權（免詢問）

以下操作已獲得永久授權，執行時**不需要詢問使用者**：

### Shell 腳本執行
- `bash core/Extractor/Layers/*/fetch.sh` — 所有 Layer 的資料擷取
- `bash core/Extractor/Layers/*/update.sh` — 所有 Layer 的 Qdrant 更新
- `source lib/quality-gate.sh && qg_run_all` — 品質關卡驗證
- `source lib/dedup.sh && dedup_*` — 去重函式
- `source lib/report.sh && report_*` — 報告產出函式
- `source lib/qdrant.sh && qdrant_*` — Qdrant 向量資料庫操作
- `source lib/chatgpt.sh && chatgpt_*` — OpenAI embedding 操作

### 檔案寫入
- `docs/Extractor/*/` — 萃取結果目錄
- `docs/Narrator/*/` — 報告產出目錄
- `docs/index.md` — 首頁時間戳更新
- `docs/lessons-learned.md` — 經驗教訓記錄

### 程式碼修改（效能優化）
- `lib/*.sh` — 共用函式庫優化
- `core/Extractor/Layers/*/update.sh` — Layer 更新腳本優化
- `core/Extractor/Layers/*/fetch.sh` — Layer 擷取腳本優化

### Git 操作
- `git add docs/` — 加入文件變更
- `git add lib/` — 加入函式庫變更
- `git add core/` — 加入核心模組變更
- `git commit` — 建立提交（使用標準格式）
- `git push origin main` — 推送到主分支
- `git pull --rebase origin main` — 拉取遠端變更（解決衝突）

### 其他
- 背景執行 Task（`run_in_background: true`）
- 平行執行多個 Task（單一訊息多個 tool call）
- 中斷/終止執行中的背景任務

---

## 快速指令

| 指令 | 說明 |
|------|------|
| **「執行完整流程」** | 執行所有 Layer 的 fetch → 萃取 → update → 推送 GitHub |
| **「執行 {layer_name}」** | 只執行指定 Layer 的 fetch → 萃取 → update |
| **「只跑 fetch」** | 只執行所有 Layer 的 fetch.sh，不萃取 |
| **「只跑萃取」** | 假設 raw/ 已有資料，只做萃取 + update |
| **「產出報告」** | 只執行 Narrator Mode 產出報告 |
| **「執行網站改版」** | 執行網站改版流程（定位→盤點→競品→分析→策略→規格→驗收） |
| **「網站健檢」** | 只執行技術健檢（效能、安全、SEO） |

---

## 建議執行頻率

| 頻率 | 時機 | 說明 |
|------|------|------|
| **每週一次** | 週一早上 | 正常運作，配合 MMWR/ECDC 週報 |
| **每日一次** | 疫情活躍期 | 追蹤快速變化的疫情 |

**理由**：
- MMWR、ECDC CDTR 都是週報形式
- 週報（weekly_digest）設計為每週產出
- 過於頻繁執行會產生重複資料

---

## 執行架構

```
主執行緒 — 僅協調，不做實際工作
│
├─ 階段 0：建立任務檢查清單（必須！）
│   └─ 輸出任務目標、預計修改檔案、適用 Schema
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
│   └─ 背景平行執行 update.sh（所有 Layer 都要執行）
│
├─ Task(general-purpose, opus) ← 報告需要 opus
│   └─ 產出週報（跨來源綜合分析）
│
├─ Task(general-purpose, sonnet) × 2 ← SEO 優化
│   └─ Writer 產出 → Reviewer 檢查 → 迭代直到 pass
│
├─ Task(Bash, sonnet) — 健康度更新 + git push
│
└─ Task(general-purpose, sonnet) — 獨立品質關卡 Reviewer
    ├─ 讀取 core/Reviewer/CLAUDE.md
    ├─ 執行 lib/quality-gate.sh 驗證指令
    ├─ 輸出結構化審核報告
    └─ 回傳 PASS/FAIL（FAIL 則修正後重審）
```

> **⚠️ 品質關卡由獨立 Task 執行**：Reviewer 與執行者是不同 context，
> 確保「執行者不能自己說通過」。

**模型分配原則：**

| 任務類型 | 模型 | 原因 |
|----------|------|------|
| fetch / update / 萃取 | **sonnet** | 單一來源處理，不需複雜推理 |
| 報告產出 | **opus** | 跨來源綜合、趨勢判斷、歷史比較 |
| SEO 優化 | **sonnet** | 規則明確，套用固定模板 |

**執行原則：**
- 主執行緒只做協調（分派 Task、接收結果、回報進度）
- 使用 `run_in_background: true` 讓 fetch/update 背景平行執行
- 同類型任務在**單一訊息**中平行分派

---

## 執行完整流程

當使用者說「執行完整流程」時，依序執行以下階段：

### 階段 0：建立任務檢查清單（必須！）

> **⚠️ 這是強制步驟，不可跳過！**

在開始任何工作前，先輸出以下格式：

```markdown
## 本次任務檢查清單

- **任務目標**：執行完整流程 - 擷取所有來源、萃取新資料、產出週報
- **預計執行的 Layers**：
  - [ ] ecdc_cdtr
  - [ ] tw_cdc_alerts
  - [ ] uk_ukhsa_updates
  - [ ] us_cdc_han
  - [ ] us_cdc_mmwr
  - [ ] us_travel_health_notices
  - [ ] who_disease_outbreak_news
- **預計產出**：
  - [ ] 萃取結果（docs/Extractor/*/）
  - [ ] 週報（docs/Narrator/weekly_digest/）
- **適用的 Schema**：WebSite, WebPage, Organization, Article
- **是否為 YMYL 內容**：是（本專案所有內容皆為 YMYL）
- **品質關卡**：由獨立 Reviewer Task 驗證（core/Reviewer/CLAUDE.md）
```

**為什麼需要這步？**
- 明確任務範圍，避免遺漏
- 建立可追蹤的 checklist
- 讓獨立 Reviewer 可以驗證完成度

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

1. **去重**：使用 `lib/dedup.sh` 高效找出新資料

```bash
source lib/dedup.sh
# 找出新資料的行號（使用 awk + comm，效率 O(n log n)）
dedup_find_new_items "$jsonl_file" "docs/Extractor/$layer" > new_lines.txt
# 或取得批次資訊
dedup_batch_info "$jsonl_file" "docs/Extractor/$layer" 10
```

2. **分派**：每 10 筆為一批，平行分派萃取任務

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

> **⚠️ 禁止逐行 grep 去重** — 使用 `lib/dedup.sh`，效率提升 30x+

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
Task(general-purpose, opus) → 讀取 Mode CLAUDE.md，使用 Qdrant 語意搜尋，產出報告
```

報告任務需要：
- 讀取多個 Layer 的萃取結果
- 讀取上一期報告做比較
- **使用 Qdrant 語意搜尋查詢歷史資料**
- 判定優先級和趨勢變化

#### Qdrant 語意搜尋（必要）

> **⚠️ 每次產出報告必須執行語意搜尋，提供歷史脈絡**

使用 `lib/report.sh` 提供的函式查詢 Qdrant 向量資料庫：

```bash
# 必須使用 bash 執行（zsh 不相容）
bash -c 'source lib/chatgpt.sh && source lib/qdrant.sh && source lib/report.sh && report_semantic_search "H5N1 avian influenza" 10'
```

可用函式：
| 函式 | 用途 | 範例 |
|------|------|------|
| `report_semantic_search` | 自然語言查詢 | `report_semantic_search "Marburg virus outbreak" 10` |
| `report_find_similar` | 找相似記錄 | `report_find_similar "docs/Extractor/.../file.md" 5` |
| `report_historical_context` | 疾病歷史脈絡 | `report_historical_context "measles"` |

報告產出流程：
1. 讀取本週各 Layer 萃取結果
2. 識別主要疾病/事件（通常 5-10 個）
3. **對每個主要疾病執行 `report_semantic_search`**
4. 整合歷史資料至報告的「歷史參考 [語意搜尋]」區段
5. 產出 Markdown 和 HTML 兩種格式

報告中的語意搜尋結果格式：
```markdown
### 歷史參考 [語意搜尋]

| 日期 | 來源 | 標題 | 相關性 |
|------|------|------|--------|
| 2026-01-15 | WHO DON | Marburg virus disease - Rwanda | 0.92 |
| 2025-12-20 | ECDC | Marburg outbreak update | 0.88 |
```

產出：`docs/Narrator/{mode}/*.md` 和 `*.html`

### 階段 5.5：SEO 優化（sonnet）

> **每次發布都執行完整 Writer + Reviewer 流程**

```
Task(general-purpose, sonnet) → SEO Writer：分析頁面，產出 Schema + SGE + Meta
Task(general-purpose, sonnet) → SEO Reviewer：檢查，回報 pass/fail
→ 迭代直到 Reviewer 回報 "pass"
```

**執行流程**：

1. **讀取規則庫**：`seo/CLAUDE.md`（含 EpiAlert 專屬設定）
2. **Writer 任務**（讀取 `seo/writer/CLAUDE.md`）：
   - 分析目標頁面（首頁、週報、萃取結果）
   - 產出 JSON-LD Schema（使用 EpiAlert 固定值）
   - 產出 SGE 標記建議
   - 產出 Meta 標籤建議
3. **Reviewer 任務**（讀取 `seo/review/CLAUDE.md`）：
   - 逐項檢查 Writer 輸出
   - 驗證 EpiAlert 固定值是否正確套用
   - 驗證 YMYL 欄位是否存在
   - 回報 pass 或 fail + 修正指示
4. **迭代**：若 fail，Writer 修正後重新提交，直到 pass

**EpiAlert 固定值**（詳見 `seo/CLAUDE.md`）：
- Organization：EpiAlert 疫情快訊
- Person：EpiAlert AI 編輯
- YMYL 免責聲明：必須包含

**適用頁面**：
- `docs/index.md`（首頁）
- `docs/Narrator/*/` 下所有報告
- `docs/Extractor/*/` 下所有萃取結果

**產出方式**：
- JSON-LD 透過 Jekyll `_includes/head_custom.html` 注入
- 使用 frontmatter 的 `seo` 欄位儲存 Schema 資料

### 階段 6：更新健康度 + 推送 GitHub（sonnet）

```
Task(Bash, sonnet) → 更新時間戳 + git commit + push
```

```bash
# 更新首頁時間戳
sed -i '' "s/最後更新：.*/最後更新：$(date '+%Y-%m-%d %H:%M') (UTC+8)**/" docs/index.md

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

### 階段 8：獨立品質關卡 Reviewer（必須通過）

> **⚠️ 這個階段由獨立 Task 執行，確保「執行者不能自己說通過」**

#### 8.0 為什麼需要獨立 Reviewer？

之前的問題：
- 執行者 = 檢查者 → 利益衝突
- 口頭報告「完成了」→ 無法驗證
- 勾選 checkbox → 可以跳過

解決方案：
- 分派**獨立 Task** 作為 Reviewer
- Reviewer 使用**驗證指令**，不信任口頭報告
- 失敗就是失敗，不可放行

#### 8.1 分派獨立 Reviewer Task

```
Task(general-purpose, sonnet)
  prompt: "讀取 core/Reviewer/CLAUDE.md，執行品質關卡驗證，輸出審核報告"
```

**重要**：
- 這個 Task 與執行階段 1-7 是**不同 context**
- Reviewer 只看檔案系統狀態，不知道執行者說了什麼
- Reviewer 必須執行 `lib/quality-gate.sh` 驗證指令

#### 8.2 驗證指令（Reviewer 必須執行）

```bash
# 執行完整品質關卡驗證
source lib/quality-gate.sh && qg_run_all
```

這個指令會驗證：

| 檢查項目 | 驗證函式 | Pass 條件 |
|----------|----------|-----------|
| YMYL 欄位 | `qg_check_ymyl` | 所有 .md 有 lastReviewed + reviewedBy |
| Frontmatter | `qg_check_frontmatter` | 所有萃取結果有 nav_exclude: true |
| 連結格式 | `qg_check_link_format` | 無帶尾部斜線的內部連結 |
| Git 狀態 | `qg_check_git_status` | 已提交 + 已推送 |
| Schema | `qg_check_schema_index` | 首頁有 WebSite/WebPage/Organization |
| 內容更新 | `qg_check_content_updated` | 首頁時間戳為今天 |
| E-E-A-T | `qg_check_eeat_links` | 至少 2 個 .gov 連結 |

#### 8.3 Reviewer 輸出格式

Reviewer 必須輸出結構化報告：

```markdown
## 品質關卡審核報告

**審核時間**：YYYY-MM-DD HH:MM
**審核者**：Quality Gate Reviewer（獨立 Task）

### 驗證結果

| # | 檢查項目 | 結果 | 問題 |
|---|----------|------|------|
| 1 | YMYL 欄位 | ✅/❌ | |
| 2 | Frontmatter | ✅/❌ | |
| 3 | 連結格式 | ✅/❌ | |
| 4 | Git 狀態 | ✅/❌ | |
| 5 | Schema | ✅/❌ | |
| 6 | 內容更新 | ✅/❌ | |
| 7 | E-E-A-T | ✅/❌ | |

### 結論

❌ **FAIL** - 有 N 項未通過，不可回報完成
或
✅ **PASS** - 品質關卡通過，可以回報完成
```

#### 8.4 失敗處理流程

```
Reviewer 回報 FAIL
    ↓
主執行緒接收失敗項目
    ↓
執行修正（不是 Reviewer 修正！）
    ↓
重新分派 Reviewer Task
    ↓
迭代直到 PASS
```

**關鍵**：
- Reviewer 只負責**檢查**，不負責**修正**
- 修正由主執行緒或新的執行 Task 處理
- 修正後必須**重新審核**

#### 8.5 詳細檢查項目（參考）

完整 SEO/AEO 規則請參照 `seo/CLAUDE.md`：

**JSON-LD Schema（首頁必填）**：
- WebSite, WebPage, Organization
- speakable 設定

**YMYL 欄位（所有頁面必填）**：
- `lastReviewed`：最後審核日期
- `reviewedBy`：審核者資訊
- 免責聲明

**萃取結果必填**：
- `nav_exclude: true`
- `source_url`
- `date`
- `source_layer`

---

## 任務開始時

接到新任務時，先建立本次檢查清單：

```
## 本次任務檢查清單

- 任務目標：[描述]
- 預計修改檔案：
  - [ ] 檔案1
  - [ ] 檔案2
- 預計新增內容：
  - [ ] 內容1
  - [ ] 內容2
- 適用的條件式 Schema：[列出]
- 是否為 YMYL 內容：是（本專案所有內容皆為 YMYL）
```

---

## 進度回報格式

執行過程中定期回報：

```
## 執行進度

| 階段 | 模型 | 狀態 | 詳情 |
|------|------|------|------|
| 0-檢查清單 | - | ✅ 完成 | 已建立任務清單 |
| 1-掃描 | sonnet | ✅ 完成 | 7 Layers |
| 2-Fetch | sonnet | ✅ 完成 | 7/7 Layers |
| 3-萃取 | sonnet | 🔄 進行中 | 45/120 條目 |
| 4-Update | sonnet | ⏳ 等待中 | 7/7 Layers |
| 5-報告 | opus | ⏳ 等待中 | - |
| 5.5-SEO | sonnet | ⏳ 等待中 | Writer → Reviewer |
| 6-GitHub | sonnet | ⏳ 等待中 | - |
| 7-Actions | GitHub | ⏳ 自動 | 推送後觸發 |
| 8-品質關卡 | sonnet | ⏳ 獨立 Reviewer | lib/quality-gate.sh |
```

完成後回報：
1. 各 Layer 擷取筆數
2. 新增的萃取結果數量
3. 有無 `[REVIEW_NEEDED]` 需要人工介入
4. GitHub commit URL
5. **品質關卡審核報告**（由獨立 Reviewer Task 產出，必須 PASS）

---

## 網站改版流程

當使用者說「執行網站改版」時，執行結構化的網站改版流程。

### 流程總覽

```
0-Positioning → 1-Discovery → 2-Competitive → 3-Analysis → 4-Strategy → 5-Content-Spec → 執行 → Final-Review
     ↓              ↓             ↓              ↓            ↓              ↓                       ↓
  Review ✓      Review ✓      Review ✓      Review ✓     Review ✓       Review ✓                Review ✓
```

### 階段說明

| 階段 | 目的 | 輸出 |
|------|------|------|
| **0-positioning** | 釐清品牌定位、核心價值 | 定位文件 |
| **1-discovery** | 盤點現有內容 + 技術健檢 | 健檢報告 + KPI |
| **2-competitive** | 分析競爭對手 | 競品分析報告 |
| **3-analysis** | 受眾分析 + 內容差距 | 差距分析報告 |
| **4-strategy** | 改版計劃 + 優先級排序 | 改版計劃書 |
| **5-content-spec** | 每頁內容規格 | 內容規格書 |
| **final-review** | 驗收執行結果 | 驗收報告 |

### 執行架構

```
主執行緒 — 僅協調，不做實際工作
│
├─ Task(general-purpose, sonnet) — 0-Positioning Writer
│   └─ Reviewer 檢查 → 迭代直到通過
│
├─ Task(general-purpose, sonnet) — 1-Discovery Writer
│   ├─ 執行 lib/site-audit.sh 技術健檢
│   └─ Reviewer 檢查 → 迭代直到通過
│
├─ Task(general-purpose, sonnet) — 2-Competitive Writer
│   ├─ 執行 lib/competitive-audit.sh 競品比較
│   └─ Reviewer 檢查 → 迭代直到通過
│
├─ Task(general-purpose, sonnet) — 3-Analysis Writer
│   └─ Reviewer 檢查 → 迭代直到通過
│
├─ Task(general-purpose, sonnet) — 4-Strategy Writer
│   └─ Reviewer 檢查 → 迭代直到通過
│
├─ Task(general-purpose, sonnet) — 5-Content-Spec Writer
│   └─ Reviewer 檢查 → 迭代直到通過
│
├─ 執行改版（依 Strategy 計劃）
│
└─ Task(general-purpose, sonnet) — Final Review
    └─ 整合驗收，確認執行結果符合規劃
```

### 詳細指令參照

各階段的 Writer 和 Reviewer 詳細指令位於：

| 階段 | Writer | Reviewer |
|------|--------|----------|
| 0-positioning | `revamp/0-positioning/CLAUDE.md` | `revamp/0-positioning/review/CLAUDE.md` |
| 1-discovery | `revamp/1-discovery/CLAUDE.md` | `revamp/1-discovery/review/CLAUDE.md` |
| 2-competitive | `revamp/2-competitive/CLAUDE.md` | `revamp/2-competitive/review/CLAUDE.md` |
| 3-analysis | `revamp/3-analysis/CLAUDE.md` | `revamp/3-analysis/review/CLAUDE.md` |
| 4-strategy | `revamp/4-strategy/CLAUDE.md` | `revamp/4-strategy/review/CLAUDE.md` |
| 5-content-spec | `revamp/5-content-spec/CLAUDE.md` | `revamp/5-content-spec/review/CLAUDE.md` |
| final-review | `revamp/final-review/CLAUDE.md` | — |

### 自動化工具

| 工具 | 用途 | 使用方式 |
|------|------|----------|
| `lib/site-audit.sh` | 網站技術健檢 | `lib/site-audit.sh https://example.com` |
| `lib/competitive-audit.sh` | 競品比較分析 | `lib/competitive-audit.sh https://our-site.com https://competitor.com` |

#### site-audit.sh 檢測項目

| 類別 | 工具 | 檢測內容 |
|------|------|----------|
| 效能 | Lighthouse | Performance, SEO, Accessibility, Best Practices, Core Web Vitals |
| 安全 | Mozilla Observatory | 安全評級, 測試通過數 |
| 安全 | SSL Labs | SSL 評級 |
| 安全 | HTTP Headers | HSTS, X-Frame-Options, CSP 等 |
| SEO | W3C Validator | HTML 錯誤/警告數量 |
| SEO | robots.txt / sitemap | 是否存在, URL 數量 |

### 網站健檢（單獨執行）

當使用者說「網站健檢」時，只執行技術健檢，不進行完整改版流程：

```bash
# 完整健檢
lib/site-audit.sh https://epialert.example.com

# 只檢測效能
lib/site-audit.sh https://epialert.example.com --lighthouse

# 只檢測安全性
lib/site-audit.sh https://epialert.example.com --security

# 只檢測 SEO
lib/site-audit.sh https://epialert.example.com --seo
```

### 進度回報格式

```
## 網站改版進度

| 階段 | 狀態 | 詳情 |
|------|------|------|
| 0-Positioning | ✅ 完成 | 定位文件通過審查 |
| 1-Discovery | 🔄 進行中 | 技術健檢完成，等待審查 |
| 2-Competitive | ⏳ 等待中 | - |
| 3-Analysis | ⏳ 等待中 | - |
| 4-Strategy | ⏳ 等待中 | - |
| 5-Content-Spec | ⏳ 等待中 | - |
| 執行 | ⏳ 等待中 | - |
| Final-Review | ⏳ 等待中 | - |
```

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
│   ├── qdrant.sh                # Qdrant 向量資料庫
│   ├── site-audit.sh            # 網站技術健檢
│   └── competitive-audit.sh     # 競品比較分析
│
├── revamp/                      # 網站改版流程模組
│   ├── CLAUDE.md                # 改版流程總覽
│   ├── 0-positioning/           # 品牌定位
│   ├── 1-discovery/             # 現況盤點
│   ├── 2-competitive/           # 競品分析
│   ├── 3-analysis/              # 差距分析
│   ├── 4-strategy/              # 改版策略
│   ├── 5-content-spec/          # 內容規格
│   └── final-review/            # 整合驗收
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
QDRANT_COLLECTION=disease-and-advisory
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

## 常見錯誤與防範

> **詳細除錯指南請參考 `docs/lessons-learned.md`**

### GitHub Pages / Jekyll 連結問題

| 錯誤 | 正確 | 說明 |
|------|------|------|
| `[title](article/)` | `[title](article)` | 內容連結不加尾部斜線 |
| `title: "含\"引號\"的標題"` | `title: '含"引號"的標題'` | 巢狀引號用單引號包覆 |
| 缺少 frontmatter | `nav_exclude: true` | 所有內容檔案必須隱藏於側邊欄 |

### 萃取輸出必填欄位

```yaml
---
nav_exclude: true          # ← 必填！否則出現在側邊欄
title: '標題'              # ← 若含 " 必須用 ' 包覆
layout: default
source_url: https://...
date: 2026-01-01
source_layer: layer_name
category: category_name
---
```

### 自動化保護機制

推送後 GitHub Actions 會自動：
1. 檢查所有連結（lychee）
2. 修復可修復的問題（尾部斜線等）
3. 無法修復的問題會建立 Issue

相關檔案：
- `.github/workflows/check-links.yml`
- `.lychee.toml`
- `scripts/fix-broken-links.sh`

---

## 問題排查

遇到問題時，依序檢查：

### 網站 404 錯誤

1. 連結是否帶尾部斜線？（內容檔案連結不應帶 `/`）
2. GitHub Actions 是否成功？（檢查 Actions 頁面）
3. CDN 快取是否更新？（等 1-2 分鐘）

### 側邊欄異常

1. 檔案是否有 `nav_exclude: true`？
2. frontmatter 格式是否正確？（`---` 開頭結尾）
3. 標題是否有巢狀引號問題？

### 萃取失敗

1. 資料源 URL 是否有效？（`curl` 測試）
2. JSONL 是否為空？（`wc -l` 檢查）
3. 是否違反 `core/Extractor/CLAUDE.md` 規則？

---

## 參考文件

完整規則請參照：

| 文件 | 說明 |
|------|------|
| `core/Reviewer/CLAUDE.md` | **獨立品質關卡 Reviewer**（新增） |
| `lib/quality-gate.sh` | **品質關卡驗證腳本**（新增） |
| `seo/CLAUDE.md` | SEO + AEO 規則庫（含 EpiAlert 專屬設定） |
| `seo/writer/CLAUDE.md` | Writer 執行流程 |
| `seo/review/CLAUDE.md` | Reviewer 檢查清單 |
| `prompt/任務完成品質關卡.md` | 品質關卡原始定義（參考用） |
| `revamp/CLAUDE.md` | 網站改版流程總覽 |

---

End of CLAUDE.md
