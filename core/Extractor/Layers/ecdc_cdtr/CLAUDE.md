# ECDC Communicable Disease Threats Report Layer

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | ecdc_cdtr（ECDC 傳染病威脅報告） |
| **Engineering function** | 擷取歐洲 CDC 的傳染病監測、風險評估與疫情報告 |
| **Collectable data** | CDTR 週報、流行病學更新、風險評估、疫情報告 |
| **Automation level** | 85% — 多 feed 合併，部分需要 WebFetch 補充 |
| **Output value** | 歐洲地區傳染病監測與風險評估的權威來源 |
| **Risk type** | 完整性風險（RSS description 可能不完整） |
| **Reviewer persona** | 資料可信度審核員、完整性審核員 |
| **WebFetch 策略** | **按需** — description 少於 200 字時使用 |

---

## Category Enum

| 英文 key | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `surveillance` | 監測報告 | CDTR 週報、監測數據、流行病學更新 |
| `risk_assessment` | 風險評估 | 快速風險評估、威脅評估報告 |
| `guidance` | 指引建議 | 技術指引、防控建議、臨床指南 |
| `outbreak_report` | 疫情報告 | 特定疫情的詳細報告 |
| `situational_update` | 情況更新 | 持續疫情的定期更新 |

> **嚴格限制**：category 只能使用上述五個值，不可自行新增。

---

## 資料來源（4 個 RSS Feeds）

| Feed 名稱 | URL | 主要內容 |
|-----------|-----|----------|
| CDTR 週報 | `https://www.ecdc.europa.eu/en/taxonomy/term/1505/feed` | 每週傳染病威脅報告 |
| 流行病學更新 | `https://www.ecdc.europa.eu/en/taxonomy/term/1310/feed` | 疫情流行病學資料 |
| 風險評估 | `https://www.ecdc.europa.eu/en/taxonomy/term/1295/feed` | 快速風險評估報告 |
| 新聞 | `https://www.ecdc.europa.eu/en/taxonomy/term/1307/feed` | ECDC 公告與新聞 |

所有 feed 合併為單一 `merged.jsonl`，並在每筆資料中標記 `feed_source`。

---

## 萃取邏輯

### 輸入欄位映射

| RSS 欄位 | 輸出欄位 | 處理邏輯 |
|----------|----------|----------|
| `title` | `title` | 直接使用 |
| `link` | `source_url` | 直接使用 |
| `pubDate` | `date` | 轉換為 ISO 8601 格式 |
| `description` | `summary` | 清理 HTML，提取純文字 |
| `feed_source` | `feed_source` | 標記來自哪個 feed（由 fetch.sh 新增）|

### Category 判定

根據 feed_source 和 title/description 內容：

| feed_source | 預設 category | 覆寫條件 |
|-------------|---------------|----------|
| cdtr | `surveillance` | - |
| epidemiological | `situational_update` | 若包含 "outbreak" → `outbreak_report` |
| risk_assessment | `risk_assessment` | - |
| news | `guidance` | 若包含 "update" → `situational_update` |

進一步關鍵詞判定：
- 包含 "rapid risk assessment", "threat assessment" → `risk_assessment`
- 包含 "guidance", "technical report", "clinical" → `guidance`
- 包含 "outbreak", "cluster", "cases" → `outbreak_report`
- 包含 "weekly", "surveillance", "monitoring" → `surveillance`
- 包含 "update", "situation" → `situational_update`

### WebFetch 觸發條件

當以下條件滿足時，使用 WebFetch：
- `description` 長度少於 200 字元
- `description` 為空或僅包含 "Read more"

### Confidence 判定

| 情況 | confidence |
|------|------------|
| description 完整（>200 字）且可判定 category | 高 |
| description 不完整，WebFetch 成功補充 | 中 |
| WebFetch 失敗，僅基於 title 和 description 萃取 | 低 |

---

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. 無法判定 category（title 和 description 都缺乏關鍵詞）
2. description 為空且 WebFetch 失敗
3. pubDate 格式異常無法解析
4. 內容看起來不是 ECDC 官方發布（可能是網站錯誤頁面）

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅因為需要 WebFetch（這是正常補充流程）
- ❌ 僅因為 description 較短但可萃取摘要
- ❌ 僅因為 category 判定為預設值

---

## 輸出格式

> **注意**：若標題包含雙引號 `"`，外層必須使用單引號 `'` 包覆。

```markdown
---
nav_exclude: true
title: '{標題}'
source_url: "{完整 ECDC 連結}"
source_layer: ecdc_cdtr
category: {surveillance|risk_assessment|guidance|outbreak_report|situational_update}
date: {YYYY-MM-DD}
confidence: {高|中|低}
feed_source: "{cdtr|epidemiological|risk_assessment|news}"
diseases: ["{disease names}"]
regions: ["{affected EU regions}"]
---

## 摘要

{2-3 句話概述報告內容}

## 詳細內容

{從 description 或 WebFetch 取得的內容}

## 相關疾病

{列出涉及的疾病名稱}

## 影響地區

{列出受影響的歐洲國家/地區}

---
*萃取時間: {ISO 8601 timestamp}*
*資料來源: ECDC ({feed_source})*
```

---

## 自我審核 Checklist

萃取前確認：
- [ ] `nav_exclude: true` 存在於 frontmatter 開頭
- [ ] `title` 若包含 `"` 則使用單引號包覆
- [ ] `source_url` 為有效的 ECDC 連結
- [ ] `date` 成功轉換為 ISO 8601
- [ ] `category` 屬於 enum 定義的五個值之一
- [ ] `feed_source` 已正確標記
- [ ] `summary` 基於原始資料，無憑空推測
- [ ] 若需 WebFetch 但失敗，已在 notes 標註
- [ ] 若符合 REVIEW_NEEDED 觸發規則，已在開頭標記

---

## 輸出範例

```markdown
---
nav_exclude: true
title: 'Communicable disease threats report, 8-14 January 2024, week 2'
source_url: "https://www.ecdc.europa.eu/en/publications-data/communicable-disease-threats-report-8-14-january-2024-week-2"
source_layer: ecdc_cdtr
category: surveillance
date: 2024-01-15
confidence: 高
feed_source: "cdtr"
diseases: ["Influenza", "COVID-19", "Measles"]
regions: ["EU/EEA"]
---

## 摘要

ECDC 發布 2024 年第 2 週傳染病威脅週報。報告涵蓋流感、COVID-19 和麻疹等
傳染病在歐盟/歐洲經濟區的監測數據與風險評估。

## 詳細內容

本週報告重點：
- 流感活動持續上升，多國達到高峰...
- COVID-19 住院率穩定...
- 麻疹疫情在部分國家持續...

## 相關疾病

- 流感（Influenza）
- COVID-19
- 麻疹（Measles）

## 影響地區

- 歐盟/歐洲經濟區全區

---
*萃取時間: 2024-01-16T09:00:00Z*
*資料來源: ECDC (cdtr)*
```
