# WHO Disease Outbreak News Layer

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | who_disease_outbreak_news（WHO 疾病疫情新聞） |
| **Engineering function** | 擷取 WHO 官方疾病疫情爆發新聞與報告 |
| **Collectable data** | 疫情爆發報告、新興疾病警報、緊急事件、調查報告 |
| **Automation level** | 90% — JSON API 結構化，部分需要 WebFetch 補充 |
| **Output value** | 全球疾病疫情的權威資訊來源 |
| **Risk type** | 完整性風險（API 回應可能不包含完整文章內容） |
| **Reviewer persona** | 資料可信度審核員、完整性審核員 |
| **WebFetch 策略** | **按需** — content 少於 500 字時使用 |

---

## Category Enum

| 英文 key | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `outbreak` | 疫情爆發 | 報告新的疾病爆發事件，通常有明確地理範圍 |
| `emergence` | 新興疾病 | 新發現或首次在某地區出現的疾病 |
| `emergency` | 公衛緊急事件 | PHEIC 或其他 WHO 宣布的緊急事件 |
| `update` | 情況更新 | 對先前報告的疫情進行更新 |
| `investigation` | 調查中 | 疑似或正在調查中的公衛事件 |

> **嚴格限制**：category 只能使用上述五個值，不可自行新增。

---

## 資料來源

- **API Endpoint**: `https://www.who.int/api/news/diseaseoutbreaknews`
- **格式**: OData JSON API
- **分頁**: 支援 `$top` 和 `$skip` 參數

---

## API 回應結構

```json
{
  "value": [
    {
      "Id": "string",
      "Title": "string",
      "PublicationDate": "ISO 8601 date",
      "Summary": "string",
      "UrlName": "string (slug)",
      "ThumbnailUrl": "string",
      "Content": "HTML string"
    }
  ]
}
```

---

## 萃取邏輯

### 輸入欄位映射

| API 欄位 | 輸出欄位 | 處理邏輯 |
|----------|----------|----------|
| `Title` | `title` | 直接使用 |
| `Id` 或組合 URL | `source_url` | 組合為 `https://www.who.int/emergencies/disease-outbreak-news/{UrlName}` |
| `PublicationDate` | `date` | 轉換為 ISO 8601 格式 |
| `Summary` | `summary` | 直接使用或從 Content 提取 |
| `Content` | `details` | 清理 HTML 標籤 |

### Category 判定

從 `Title` 和 `Summary` 中判定：
- 包含 "outbreak", "cases reported" → `outbreak`
- 包含 "novel", "first", "emerging" → `emergence`
- 包含 "PHEIC", "emergency", "IHR" → `emergency`
- 包含 "update", "situation" → `update`
- 包含 "investigation", "suspected", "unknown" → `investigation`
- 無法判定時 → `outbreak`（預設）

### WebFetch 觸發條件

當以下條件滿足時，使用 WebFetch 取得完整內容：
- `Content` 欄位為空
- `Content` 長度少於 500 字元
- `Summary` 為空

### Confidence 判定

| 情況 | confidence |
|------|------------|
| Content 完整（>500 字）且可判定 category | 高 |
| Content 不完整但 Summary 足夠，需 WebFetch | 中 |
| WebFetch 失敗，僅基於 Summary 萃取 | 低 |

---

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. 無法判定 category（title 和 summary 都缺乏關鍵詞）
2. Content 為空且 WebFetch 失敗
3. PublicationDate 格式異常無法解析
4. Title 為空或僅包含通用文字

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅因為需要 WebFetch（這是正常補充流程）
- ❌ 僅因為 Content 較短但 Summary 足夠
- ❌ 僅因為 category 判定為預設值 `outbreak`

---

## 輸出格式

```markdown
---
title: "{標題}"
source_url: "{完整 WHO 連結}"
source_layer: who_disease_outbreak_news
category: {outbreak|emergence|emergency|update|investigation}
date: {YYYY-MM-DD}
confidence: {高|中|低}
who_id: "{WHO 內部 ID}"
regions: ["{affected regions}"]
diseases: ["{disease names}"]
---

## 摘要

{2-3 句話概述疫情內容}

## 詳細內容

{從 Content 或 WebFetch 取得的完整內容}

## 影響地區

{列出受影響的國家/地區}

## 相關疾病

{列出涉及的疾病名稱}

---
*萃取時間: {ISO 8601 timestamp}*
*資料來源: WHO Disease Outbreak News*
```

---

## 自我審核 Checklist

萃取前確認：
- [ ] `source_url` 為有效的 WHO 連結
- [ ] `date` 成功轉換為 ISO 8601
- [ ] `category` 屬於 enum 定義的五個值之一
- [ ] `summary` 基於原始資料，無憑空推測
- [ ] 若需 WebFetch 但失敗，已在 notes 標註
- [ ] 若符合 REVIEW_NEEDED 觸發規則，已在開頭標記

---

## 輸出範例

```markdown
---
title: "Mpox - Democratic Republic of the Congo"
source_url: "https://www.who.int/emergencies/disease-outbreak-news/item/2024-DON501"
source_layer: who_disease_outbreak_news
category: outbreak
date: 2024-01-10
confidence: 高
who_id: "2024-DON501"
regions: ["Democratic Republic of the Congo", "Central Africa"]
diseases: ["Mpox", "Monkeypox"]
---

## 摘要

剛果民主共和國報告 Mpox（猴痘）疫情持續擴大，病例數較去年同期增加。
WHO 持續監測並提供技術支援。

## 詳細內容

截至 2024 年 1 月，剛果民主共和國已報告超過 X 例確診病例...

## 影響地區

- 剛果民主共和國
- 中非地區

## 相關疾病

- Mpox（猴痘）

---
*萃取時間: 2024-01-11T08:00:00Z*
*資料來源: WHO Disease Outbreak News*
```
