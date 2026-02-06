# 台灣疾病管制署警報 Layer

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | tw_cdc_alerts（台灣疾管署警報） |
| **Engineering function** | 擷取台灣疾管署新聞稿、致醫界通函與傳染病資訊 |
| **Collectable data** | 新聞稿、致醫界通函、傳染病介紹、英文新聞 |
| **Automation level** | 75% — RSS 僅提供標題與連結，必須使用 WebFetch |
| **Output value** | 台灣地區傳染病疫情的官方一手資訊 |
| **Risk type** | 完整性風險（RSS 資訊量極少）、語言風險（需處理中英文） |
| **Reviewer persona** | 資料可信度審核員、完整性審核員 |
| **WebFetch 策略** | **必用** — RSS 只有標題與連結，無 description 內容 |

---

## Category Enum

| 英文 key | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `domestic_outbreak` | 本土疫情 | 報告本土確診病例、社區傳播、群聚事件 |
| `imported_case` | 境外移入 | 報告境外移入病例、入境檢疫 |
| `policy` | 政策公告 | 防疫政策調整、邊境管制、疫苗政策 |
| `medical_advisory` | 致醫界通函 | 致醫療院所的專業通知與建議 |
| `disease_info` | 傳染病資訊 | 傳染病介紹、衛教資訊、預防指引 |

> **嚴格限制**：category 只能使用上述五個值，不可自行新增。

---

## 資料來源（4 個 RSS Feeds）

| Feed 名稱 | 語言 | URL |
|-----------|------|-----|
| 新聞稿 | 中文 | `https://www.cdc.gov.tw/RSS/RssXml/Hh094B49-DRwe2RR4eFfrQ?type=1` |
| 致醫界通函 | 中文 | `https://www.cdc.gov.tw/RSS/RssXml/khD5i5xbqmYc8zCDhJimNg?type=1` |
| 傳染病介紹 | 中文 | `https://www.cdc.gov.tw/RSS/RssXml/M8GG46VTKYT2o1VJTKvl7A?type=2` |
| 英文新聞 | 英文 | `https://www.cdc.gov.tw/En/RSS/RssXml/sOn2_m9QgxKqhZ7omgiz1A?type=1` |

所有 feed 合併為單一 `merged.jsonl`，並標記 `feed_source` 和 `language`。

---

## 萃取邏輯

### 輸入欄位映射

| RSS 欄位 | 輸出欄位 | 處理邏輯 |
|----------|----------|----------|
| `title` | `title` | 直接使用 |
| `link` | `source_url` | 直接使用 |
| `pubDate` | `date` | 轉換為 ISO 8601 格式 |
| `description` | - | 通常為空或僅有連結，不使用 |
| WebFetch 結果 | `summary`, `details` | **必須** WebFetch 取得完整內容 |

### Category 判定

根據 feed_source 和 WebFetch 內容：

| feed_source | 預設 category | 關鍵詞覆寫 |
|-------------|---------------|------------|
| news_zh | `domestic_outbreak` | 見下方 |
| medical_zh | `medical_advisory` | - |
| disease_zh | `disease_info` | - |
| news_en | `domestic_outbreak` | 見下方 |

關鍵詞判定（中文）：
- 包含「境外移入」、「入境」、「旅遊」 → `imported_case`
- 包含「本土」、「社區」、「群聚」 → `domestic_outbreak`
- 包含「政策」、「措施」、「規定」、「調整」 → `policy`
- 包含「致醫界」、「醫療院所」、「臨床」 → `medical_advisory`
- 包含「介紹」、「預防」、「衛教」 → `disease_info`

關鍵詞判定（英文）：
- 包含 "imported", "traveler", "entry" → `imported_case`
- 包含 "domestic", "local", "community", "cluster" → `domestic_outbreak`
- 包含 "policy", "measure", "regulation" → `policy`

### WebFetch 使用規則

> **此 Layer WebFetch 為必用策略**

1. **必須**對每筆資料執行 WebFetch
2. 從 `link` 欄位取得完整頁面內容
3. WebFetch 失敗時，**仍然輸出**但：
   - `confidence` 設為「低」
   - `notes` 標註「WebFetch 失敗，僅基於標題萃取」
   - **必須**觸發 `[REVIEW_NEEDED]`

### Confidence 判定

| 情況 | confidence |
|------|------------|
| WebFetch 成功，內容完整 | 高 |
| WebFetch 成功，但內容較短（<200 字） | 中 |
| WebFetch 失敗，僅基於標題 | 低 |

---

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. WebFetch 失敗（此 Layer 為必用 WebFetch）
2. 無法判定 category（標題和內容都缺乏關鍵詞）
3. pubDate 格式異常無法解析
4. WebFetch 返回錯誤頁面（如 404、維護頁面）

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅因為內容為中文（這是正常的）
- ❌ 僅因為 category 判定為預設值
- ❌ 僅因為 RSS 本身缺乏 description（這是結構性特徵）

---

## 輸出格式

> **注意**：若標題包含雙引號 `"`，外層必須使用單引號 `'` 包覆。

```markdown
---
nav_exclude: true
title: '{標題}'
source_url: "{完整 CDC 連結}"
source_layer: tw_cdc_alerts
category: {domestic_outbreak|imported_case|policy|medical_advisory|disease_info}
date: {YYYY-MM-DD}
confidence: {高|中|低}
language: {zh|en}
feed_source: "{news_zh|medical_zh|disease_zh|news_en}"
diseases: ["{disease names}"]
regions: ["{affected regions}"]
notes: "{補充說明，如 WebFetch 狀態}"
---

## 摘要

{2-3 句話概述內容，使用與原文相同的語言}

## 詳細內容

{從 WebFetch 取得的完整內容}

## 相關疾病

{列出涉及的疾病名稱}

## 影響地區

{列出受影響的地區（台灣縣市或國家）}

---
*萃取時間: {ISO 8601 timestamp}*
*資料來源: 衛生福利部疾病管制署*
```

---

## 自我審核 Checklist

萃取前確認：
- [ ] `nav_exclude: true` 存在於 frontmatter 開頭
- [ ] `title` 若包含 `"` 則使用單引號包覆
- [ ] `source_url` 為有效的 CDC 連結
- [ ] `date` 成功轉換為 ISO 8601
- [ ] `category` 屬於 enum 定義的五個值之一
- [ ] `language` 已正確標記（zh 或 en）
- [ ] `feed_source` 已正確標記
- [ ] 已執行 WebFetch（此 Layer 為必用）
- [ ] 若 WebFetch 失敗，已標記 `[REVIEW_NEEDED]`
- [ ] `summary` 基於原始資料，無憑空推測

---

## 輸出範例（中文）

```markdown
---
nav_exclude: true
title: '國內新增1例本土登革熱確定病例，籲請民眾加強防蚊措施'
source_url: "https://www.cdc.gov.tw/Bulletin/Detail/xxxxx"
source_layer: tw_cdc_alerts
category: domestic_outbreak
date: 2024-01-15
confidence: 高
language: zh
feed_source: "news_zh"
diseases: ["登革熱"]
regions: ["高雄市"]
---

## 摘要

疾管署公布國內新增 1 例本土登革熱確定病例，個案居住於高雄市。
疾管署呼籲民眾加強清除積水容器、落實防蚊措施。

## 詳細內容

疾病管制署今（15）日公布國內新增 1 例本土登革熱確定病例，
為高雄市前鎮區 60 多歲女性...

## 相關疾病

- 登革熱（Dengue fever）

## 影響地區

- 高雄市前鎮區

---
*萃取時間: 2024-01-15T10:00:00+08:00*
*資料來源: 衛生福利部疾病管制署*
```

## 輸出範例（英文）

```markdown
---
nav_exclude: true
title: 'Taiwan CDC confirms 1 new domestic dengue case'
source_url: "https://www.cdc.gov.tw/En/Bulletin/Detail/xxxxx"
source_layer: tw_cdc_alerts
category: domestic_outbreak
date: 2024-01-15
confidence: 高
language: en
feed_source: "news_en"
diseases: ["Dengue fever"]
regions: ["Kaohsiung City"]
---

## 摘要

Taiwan CDC confirmed 1 new domestic dengue case in Kaohsiung City.
The public is advised to strengthen mosquito prevention measures.

## 詳細內容

The Taiwan Centers for Disease Control (Taiwan CDC) today confirmed
1 new domestic dengue case...

## 相關疾病

- Dengue fever

## 影響地區

- Kaohsiung City

---
*萃取時間: 2024-01-15T10:00:00+08:00*
*資料來源: Taiwan Centers for Disease Control*
```
