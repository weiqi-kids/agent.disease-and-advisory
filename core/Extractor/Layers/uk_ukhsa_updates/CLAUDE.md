# UK UKHSA Updates Layer

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | uk_ukhsa_updates（英國健康安全署更新） |
| **Engineering function** | 擷取 UKHSA 官方發布、疫情報告與指引 |
| **Collectable data** | 監測報告、疫情公告、指引文件、政策更新、研究報告 |
| **Automation level** | 85% — 多 Atom feed 合併，部分需要 WebFetch |
| **Output value** | 英國公衛機構的官方疫情與指引資訊 |
| **Risk type** | 完整性風險（Atom feed 可能資訊有限） |
| **Reviewer persona** | 資料可信度審核員、完整性審核員 |
| **WebFetch 策略** | **按需** — content/summary 不足時補充 |

---

## Category Enum

| 英文 key | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `surveillance` | 監測報告 | 週報、監測數據、流行病學報告 |
| `outbreak` | 疫情公告 | 疫情爆發通知、病例報告 |
| `guidance` | 指引文件 | 臨床指引、防控建議、技術指南 |
| `policy` | 政策更新 | 政策公告、法規變更 |
| `research` | 研究報告 | 科學研究、評估報告 |

> **嚴格限制**：category 只能使用上述五個值，不可自行新增。

---

## 資料來源（3 個 Atom Feeds）

| Feed 名稱 | URL | 主要內容 |
|-----------|-----|----------|
| UKHSA 官方 | `https://www.gov.uk/government/organisations/uk-health-security-agency.atom` | 官方發布 |
| UKHSA 新聞 | `https://www.gov.uk/search/news-and-communications.atom?organisations[]=uk-health-security-agency` | 新聞與公告 |
| UKHSA 部落格 | `https://ukhsa.blog.gov.uk/feed/` | 技術文章與分析 |

所有 feed 合併為單一 `merged.jsonl`，並標記 `feed_source`。

---

## Atom Feed 特殊處理

Atom feed 結構與 RSS 不同：
- `<entry>` 對應 RSS 的 `<item>`
- `<title>` → title
- `<link href="...">` → link
- `<updated>` 或 `<published>` → pubDate
- `<summary>` 或 `<content>` → description

fetch.sh 需處理 Atom 格式轉換。

---

## 萃取邏輯

### 輸入欄位映射

| Atom 欄位 | 輸出欄位 | 處理邏輯 |
|-----------|----------|----------|
| `title` | `title` | 直接使用 |
| `link[@href]` | `source_url` | 提取 href 屬性 |
| `updated` 或 `published` | `date` | 轉換為 ISO 8601 格式 |
| `summary` 或 `content` | `summary` | 清理 HTML |

### Category 判定

根據 feed_source 和內容：

| feed_source | 預設 category | 關鍵詞覆寫 |
|-------------|---------------|------------|
| ukhsa_official | `guidance` | 見下方 |
| ukhsa_news | `outbreak` | 見下方 |
| ukhsa_blog | `research` | 見下方 |

關鍵詞判定：
- 包含 "surveillance", "weekly", "report", "data" → `surveillance`
- 包含 "outbreak", "cases", "cluster", "alert" → `outbreak`
- 包含 "guidance", "guideline", "recommendation" → `guidance`
- 包含 "policy", "regulation", "measure" → `policy`
- 包含 "research", "study", "analysis", "evaluation" → `research`

### WebFetch 觸發條件

當以下條件滿足時使用 WebFetch：
- `summary`/`content` 長度少於 200 字元
- 內容為空

### Confidence 判定

| 情況 | confidence |
|------|------------|
| summary/content 完整（>200 字）| 高 |
| 內容不完整，WebFetch 成功補充 | 中 |
| WebFetch 失敗，僅基於標題萃取 | 低 |

---

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. 無法判定 category
2. summary/content 為空且 WebFetch 失敗
3. date 格式異常無法解析
4. 內容看起來不是 UKHSA 相關（可能是網站錯誤）

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅因為需要 WebFetch
- ❌ 僅因為 category 判定為預設值
- ❌ 僅因為來自部落格 feed

---

## 輸出格式

```markdown
---
title: "{標題}"
source_url: "{完整連結}"
source_layer: uk_ukhsa_updates
category: {surveillance|outbreak|guidance|policy|research}
date: {YYYY-MM-DD}
confidence: {高|中|低}
feed_source: "{ukhsa_official|ukhsa_news|ukhsa_blog}"
diseases: ["{disease names}"]
regions: ["{affected UK regions}"]
---

## 摘要

{2-3 句話概述內容}

## 詳細內容

{從 summary/content 或 WebFetch 取得的內容}

## 相關疾病

{列出涉及的疾病名稱}

---
*萃取時間: {ISO 8601 timestamp}*
*資料來源: UK Health Security Agency*
```

---

## 自我審核 Checklist

萃取前確認：
- [ ] `source_url` 為有效的 gov.uk 或 ukhsa.blog 連結
- [ ] `date` 成功轉換為 ISO 8601
- [ ] `category` 屬於 enum 定義的五個值之一
- [ ] `feed_source` 已正確標記
- [ ] `summary` 基於原始資料，無憑空推測
- [ ] 若需 WebFetch 但失敗，已在 notes 標註
- [ ] 若符合 REVIEW_NEEDED 觸發規則，已在開頭標記
