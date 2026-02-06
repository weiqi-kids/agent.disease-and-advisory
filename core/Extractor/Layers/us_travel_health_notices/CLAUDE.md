# US CDC Travel Health Notices Layer

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | us_travel_health_notices（美國 CDC 旅遊健康通知） |
| **Engineering function** | 擷取 CDC 旅遊健康通知，包含疫情警示等級 |
| **Collectable data** | 旅遊健康通知（Level 1-3）、已存檔通知 |
| **Automation level** | 90% — RSS 結構完整，等級分類明確 |
| **Output value** | 國際旅遊疫情風險評估的權威來源 |
| **Risk type** | 時效性風險（旅遊建議需及時更新） |
| **Reviewer persona** | 時效性審核員、資料可信度審核員 |
| **WebFetch 策略** | **按需** — description 不足時補充詳情 |

---

## Category Enum

| 英文 key | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `level_3_avoid` | Level 3: 避免非必要旅行 | Warning - Avoid Nonessential Travel |
| `level_2_practice` | Level 2: 加強防護 | Alert - Practice Enhanced Precautions |
| `level_1_watch` | Level 1: 注意 | Watch - Practice Usual Precautions |
| `archived` | 已存檔 | 過期或已解除的通知 |

> **嚴格限制**：category 只能使用上述四個值，不可自行新增。

---

## 資料來源

- **RSS Feed**: `https://wwwnc.cdc.gov/travel/rss/notices.xml`
- **內容類型**: 旅遊健康通知

---

## 萃取邏輯

### 輸入欄位映射

| RSS 欄位 | 輸出欄位 | 處理邏輯 |
|----------|----------|----------|
| `title` | `title` | 直接使用，通常包含等級和目的地 |
| `link` | `source_url` | 直接使用 |
| `pubDate` | `date` | 轉換為 ISO 8601 格式 |
| `description` | `summary` | 清理 HTML，提取純文字 |

### Category 判定

從 title 或 description 判定等級：
- 包含 "Level 3", "Warning", "Avoid" → `level_3_avoid`
- 包含 "Level 2", "Alert", "Enhanced" → `level_2_practice`
- 包含 "Level 1", "Watch", "Usual" → `level_1_watch`
- 包含 "Archive", "Removed", "Past" → `archived`
- 預設 → `level_1_watch`

### 額外欄位提取

從內容中提取：
- `destination`: 目的地國家/地區
- `disease`: 相關疾病
- `alert_level`: 原始等級文字

### WebFetch 觸發條件

當以下條件滿足時使用 WebFetch：
- `description` 長度少於 200 字元
- 無法判定 destination

### Confidence 判定

| 情況 | confidence |
|------|------------|
| 等級和目的地都能明確判定 | 高 |
| 等級可判定但目的地不確定 | 中 |
| 無法判定等級 | 低 |

---

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. 無法判定 alert level（Level 1/2/3）
2. 無法識別目的地
3. pubDate 格式異常無法解析
4. description 為空且 WebFetch 失敗

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅因為是已存檔的通知
- ❌ 僅因為 description 較短但可判定等級

---

## 輸出格式

```markdown
---
title: "{標題}"
source_url: "{完整 CDC 連結}"
source_layer: us_travel_health_notices
category: {level_3_avoid|level_2_practice|level_1_watch|archived}
date: {YYYY-MM-DD}
confidence: {高|中|低}
destination: "{目的地國家/地區}"
disease: "{相關疾病}"
alert_level: "{原始等級文字}"
---

## 摘要

{2-3 句話概述通知內容}

## 詳細內容

{從 description 或 WebFetch 取得的內容}

## 旅遊建議

{列出具體的旅遊建議}

---
*萃取時間: {ISO 8601 timestamp}*
*資料來源: CDC Travel Health Notices*
```

---

## 自我審核 Checklist

萃取前確認：
- [ ] `source_url` 為有效的 CDC 旅遊健康連結
- [ ] `date` 成功轉換為 ISO 8601
- [ ] `category` 正確反映等級（level_1/2/3 或 archived）
- [ ] `destination` 已識別
- [ ] `summary` 基於原始資料，無憑空推測
- [ ] 若需 WebFetch 但失敗，已在 notes 標註
- [ ] 若符合 REVIEW_NEEDED 觸發規則，已在開頭標記
