# US CDC Health Alert Network (HAN) Layer

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | us_cdc_han（美國 CDC 健康警報網絡） |
| **Engineering function** | 擷取 CDC 官方健康警報、公告和通知 |
| **Collectable data** | 健康警報（Health Alerts）、公告（Advisories）、更新（Updates）、資訊聲明（Info Service） |
| **Automation level** | 95% — RSS 結構完整，無需 WebFetch |
| **Output value** | 美國官方疫情警報與建議的一手資訊 |
| **Risk type** | 時效性風險（警報需及時處理） |
| **Reviewer persona** | 時效性審核員、資料可信度審核員 |
| **WebFetch 策略** | **不使用** — RSS description 包含完整內容 |

---

## Category Enum

| 英文 key | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `alert` | 健康警報 | HAN 類型為 "Health Alert"，表示需要立即行動 |
| `advisory` | 健康公告 | HAN 類型為 "Health Advisory"，提供重要建議 |
| `update` | 健康更新 | HAN 類型為 "Update"，更新先前發布的資訊 |
| `information` | 資訊聲明 | HAN 類型為 "Info Service"，提供背景資訊 |

> **嚴格限制**：category 只能使用上述四個值，不可自行新增。

---

## 資料來源

- **RSS Feed**: `https://tools.cdc.gov/api/v2/resources/media/413690.rss`
- **備用**: 若主 feed 失效，檢查 `https://www.cdc.gov/han/index.html`

---

## 萃取邏輯

### 輸入欄位映射

| RSS 欄位 | 輸出欄位 | 處理邏輯 |
|----------|----------|----------|
| `title` | `title` | 直接使用，保留 HAN 編號 |
| `link` | `source_url` | 直接使用 |
| `pubDate` | `date` | 轉換為 ISO 8601 格式 |
| `description` | `summary`, `details` | 解析 HTML，提取摘要和詳細內容 |

### Category 判定

從 `title` 或 `description` 中提取 HAN 類型：
- 包含 "Health Alert" → `alert`
- 包含 "Health Advisory" → `advisory`
- 包含 "Update" → `update`
- 包含 "Info Service" 或無法判定 → `information`

### Confidence 判定

| 情況 | confidence |
|------|------------|
| title 包含明確 HAN 編號且 description 完整 | 高 |
| description 部分內容缺失 | 中 |
| 無法解析 HAN 類型 | 低 |

---

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. 無法從 title 或 description 判定 HAN 類型（category）
2. pubDate 格式異常無法解析
3. description 為空或僅包含 "Click for more information"

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅因為是單一來源（CDC 為權威來源，這是結構性特徵）
- ❌ 僅因為 description 較短（只要能萃取摘要即可）
- ❌ 僅因為沒有交叉驗證（CDC HAN 本身即為一手資訊）

---

## 輸出格式

> **注意**：若標題包含雙引號 `"`，外層必須使用單引號 `'` 包覆。

```markdown
---
nav_exclude: true
title: '{HAN 標題}'
source_url: "{原始連結}"
source_layer: us_cdc_han
category: {alert|advisory|update|information}
date: {YYYY-MM-DD}
confidence: {高|中|低}
han_id: "{HAN 編號，如 HAN-00123}"
---

## 摘要

{2-3 句話概述警報內容}

## 詳細內容

{從 description 解析的完整內容}

## 建議行動

{如果 description 中包含建議行動，提取並列出}

---
*萃取時間: {ISO 8601 timestamp}*
```

---

## 自我審核 Checklist

萃取前確認：
- [ ] `nav_exclude: true` 存在於 frontmatter 開頭
- [ ] `title` 若包含 `"` 則使用單引號包覆
- [ ] `source_url` 為有效的 CDC 連結
- [ ] `date` 成功轉換為 ISO 8601
- [ ] `category` 屬於 enum 定義的四個值之一
- [ ] `han_id` 已從標題中提取（格式：HAN-XXXXX）
- [ ] `summary` 基於原始 description，無憑空推測
- [ ] 若符合 REVIEW_NEEDED 觸發規則，已在開頭標記

---

## 輸出範例

```markdown
---
nav_exclude: true
title: 'Health Alert: Increase in Respiratory Syncytial Virus (RSV) Activity'
source_url: "https://emergency.cdc.gov/han/2024/han00123.asp"
source_layer: us_cdc_han
category: alert
date: 2024-01-15
confidence: 高
han_id: "HAN-00123"
---

## 摘要

CDC 發布健康警報，警示醫療院所注意呼吸道合胞病毒（RSV）活動增加。
警報建議加強監測，特別關注高風險群體。

## 詳細內容

近期監測數據顯示，全美多個地區的 RSV 陽性率明顯上升...

## 建議行動

- 醫療院所應加強 RSV 檢測
- 高風險群體（嬰幼兒、老年人）需特別關注
- 落實呼吸道衛生措施

---
*萃取時間: 2024-01-15T10:30:00Z*
```
