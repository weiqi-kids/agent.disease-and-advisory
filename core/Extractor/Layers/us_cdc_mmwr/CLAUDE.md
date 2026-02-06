# US CDC MMWR Layer

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | us_cdc_mmwr（美國 CDC 發病率與死亡率週報） |
| **Engineering function** | 擷取 CDC Morbidity and Mortality Weekly Report 發布 |
| **Collectable data** | 監測摘要、疫情報告、科學報告、病例系列、生命統計 |
| **Automation level** | 90% — RSS 結構完整，部分需要 WebFetch 補充詳情 |
| **Output value** | 美國官方流行病學數據與疫情分析的權威來源 |
| **Risk type** | 時效性風險（週報需定期追蹤） |
| **Reviewer persona** | 資料可信度審核員、科學準確性審核員 |
| **WebFetch 策略** | **按需** — description 完整時不需要，較短時補充 |

---

## Category Enum

| 英文 key | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `surveillance_summary` | 監測摘要 | 週報監測數據彙總、趨勢分析 |
| `outbreak_report` | 疫情報告 | 特定疫情的調查與報告 |
| `scientific_report` | 科學報告 | 研究報告、方法學文章 |
| `case_series` | 病例系列 | 病例報告、臨床觀察 |
| `vital_statistics` | 生命統計 | 死亡率、出生率等統計數據 |

> **嚴格限制**：category 只能使用上述五個值，不可自行新增。

---

## 資料來源

- **RSS Feed**: `https://tools.cdc.gov/api/v2/resources/media/342778.rss`
- **內容類型**: MMWR 週報文章

---

## 萃取邏輯

### 輸入欄位映射

| RSS 欄位 | 輸出欄位 | 處理邏輯 |
|----------|----------|----------|
| `title` | `title` | 直接使用 |
| `link` | `source_url` | 直接使用 |
| `pubDate` | `date` | 轉換為 ISO 8601 格式 |
| `description` | `summary` | 清理 HTML，提取純文字 |

### Category 判定

從 title 和 description 判定：
- 包含 "Surveillance", "Weekly", "Summary" → `surveillance_summary`
- 包含 "Outbreak", "Investigation", "Cluster" → `outbreak_report`
- 包含 "Research", "Study", "Analysis", "Methods" → `scientific_report`
- 包含 "Case", "Clinical", "Patient" → `case_series`
- 包含 "Vital", "Mortality", "Birth", "Death" → `vital_statistics`
- 預設 → `surveillance_summary`

### WebFetch 觸發條件

當以下條件滿足時使用 WebFetch：
- `description` 長度少於 300 字元
- `description` 為空

### Confidence 判定

| 情況 | confidence |
|------|------------|
| description 完整（>300 字）| 高 |
| description 不完整，WebFetch 成功補充 | 中 |
| WebFetch 失敗，僅基於 description 萃取 | 低 |

---

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. 無法判定 category
2. description 為空且 WebFetch 失敗
3. pubDate 格式異常無法解析

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅因為 description 較短但足以判定類別
- ❌ 僅因為 category 判定為預設值

---

## 輸出格式

> **注意**：若標題包含雙引號 `"`，外層必須使用單引號 `'` 包覆。

```markdown
---
nav_exclude: true
title: '{標題}'
source_url: "{完整 CDC 連結}"
source_layer: us_cdc_mmwr
category: {surveillance_summary|outbreak_report|scientific_report|case_series|vital_statistics}
date: {YYYY-MM-DD}
confidence: {高|中|低}
mmwr_volume: "{卷號，如有}"
mmwr_issue: "{期號，如有}"
---

## 摘要

{2-3 句話概述報告內容}

## 詳細內容

{從 description 或 WebFetch 取得的內容}

## 關鍵發現

{如果內容包含關鍵發現，列出}

---
*萃取時間: {ISO 8601 timestamp}*
*資料來源: CDC MMWR*
```

---

## 自我審核 Checklist

萃取前確認：
- [ ] `nav_exclude: true` 存在於 frontmatter 開頭
- [ ] `title` 若包含 `"` 則使用單引號包覆
- [ ] `source_url` 為有效的 CDC MMWR 連結
- [ ] `date` 成功轉換為 ISO 8601
- [ ] `category` 屬於 enum 定義的五個值之一
- [ ] `summary` 基於原始資料，無憑空推測
- [ ] 若需 WebFetch 但失敗，已在 notes 標註
- [ ] 若符合 REVIEW_NEEDED 觸發規則，已在開頭標記
