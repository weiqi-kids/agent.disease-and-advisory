---
title: 錯誤與教訓紀錄
layout: default
nav_exclude: true
---

# 錯誤與教訓紀錄

本文件記錄系統建設過程中發現的問題與教訓，避免未來重複犯錯。

---

## 1. 資料源可用性假設錯誤

### 1.1 「大型機構一定有 RSS」— 錯誤

**錯誤假設**：WHO、各國 CDC 等大型衛生機構一定提供 RSS feed。

**實際情況**：

| 機構 | RSS 狀態 | 實際提供 |
|------|---------|---------|
| WHO | ❌ 舊 RSS 已 404 | JSON OData API |
| KDCA (韓國) | ❌ 完全無 RSS | 僅 HTML 頁面 + data.go.kr API（需註冊） |
| NIID/JIHS (日本感染研) | ❌ 無 RSS | 僅 HTML 頁面 |
| FORTH (日本檢疫) | ❌ 無 RSS | 僅 HTML 頁面 |
| Singapore MOH Newsroom | ❌ 無 RSS，403 擋 | data.gov.sg API |

**教訓**：
- 在設計 Layer 前，**必須先驗證 RSS/API 實際可用性**
- 不可假設「應該有」，要實際 `curl` 測試
- 準備 fallback 方案：HTML scraping 或替代 API

---

### 1.2 「RSS URL 格式可以猜」— 錯誤

**錯誤假設**：RSS URL 通常是 `/rss.xml`、`/feed/`、`/rss/` 等標準路徑。

**實際情況**：

| 機構 | 嘗試的 URL | 實際 URL |
|------|-----------|---------|
| WHO | `/feeds/entity/don/en/rss.xml` | 已停用，改用 `/api/news/diseaseoutbreaknews` |
| Taiwan CDC | `/rss` | `/RSS/RssXml/{GUID}?type={N}`（需要特定 GUID） |
| ECDC | `/en/rss.xml` (404) | `/en/taxonomy/term/{ID}/feed` |
| MHLW | `/rss/` | `/stf/news.rdf`（RSS 1.0） |

**教訓**：
- RSS URL 格式**無法猜測**，必須從官網 RSS 頁面或 `<link rel="alternate">` 取得
- 優先查找官方 RSS 索引頁（如 `https://www.ecdc.europa.eu/en/rss-feeds`）
- 驗證時要檢查 HTTP 狀態碼和 Content-Type

---

### 1.3 「資料源是穩定的」— 錯誤

**錯誤假設**：一旦找到可用的資料源，它會持續可用。

**實際情況**：

| 事件 | 時間 | 影響 |
|------|------|------|
| ProMED RSS 關閉 | 2023-07 | 全球疫情早期預警重要來源消失 |
| WHO RSS 遷移至 API | 不明 | 所有依賴舊 URL 的系統失效 |
| 日本 NIID 合併為 JIHS | 2025-04 | 域名從 `niid.go.jp` 改為 `niid.jihs.go.jp` |
| Google Trends API 變更 | 2022-01-01 | 歷史資料不相容 |

**教訓**：
- 建立**資料源健康度監控**（fetch.sh 失敗時告警）
- 記錄每個資料源的**替代方案**
- 定期（每季）驗證資料源仍然可用
- 在 `docs/explored.md` 記錄「已排除」的來源和原因

---

## 2. 架構設計錯誤

### 2.1 Type A 和 Type B 混為一談

**錯誤**：將「外部資料擷取」和「衍生指標計算」都設計為 Layer。

**問題**：

| 類型 | 資料來源 | fetch.sh 行為 |
|------|---------|--------------|
| Type B (Policy) | 外部 RSS/API | 下載外部資料 |
| Type A (Signal) | 外部 API | 呼叫 API |
| Type A (Derived) | **其他 Layer 的產出** | 無外部來源，是計算 |

`country_policy_change_index`、`travel_friction_index` 等是從 Type B Layer 產出**計算**出來的，不是從外部擷取的。它們沒有 `fetch.sh` 可執行。

**教訓**：
- **衍生指標不是 Layer，是 Narrator Mode**
- Layer 定義：有外部資料來源、有 fetch.sh、產出 raw JSONL
- Mode 定義：讀取 Layer 產出、跨來源綜合分析、產出報告

**修正**：
```
Layer（Extractor）→ 只做外部資料擷取
Mode（Narrator）→ 包含衍生指標計算 + 報告產出
```

---

### 2.2 動態參數化 Layer 超出架構支援

**錯誤設計**：`country_entry_rules_{code}` 使用 `{code}` 作為動態參數。

**問題**：CLAUDE.md 架構是「一個目錄 = 一個 Layer」，不支援參數化展開。

**可行方案比較**：

| 方案 | 優點 | 缺點 |
|------|------|------|
| 每國一個 Layer 目錄 | 架構不用改 | 目錄爆炸（20+ 國家） |
| 一個 Layer 抓多國 | 目錄簡潔 | category enum 複雜化 |
| 納入各國 CDC Layer | 最簡潔 | 萃取邏輯分散 |

**教訓**：
- 設計 Layer 時，先確認**是否符合「一目錄一來源」原則**
- 如果來源有多個變體（多國、多語言），在 Layer 內部用 category 處理，而非創建多個 Layer
- 或重新思考是否該來源應該合併到其他 Layer

---

### 2.3 JSON API 不等於 RSS

**錯誤假設**：所有 `fetch.sh` 都可以用 `rss_fetch` + `rss_extract_items_jsonl`。

**實際情況**：

| 來源 | 格式 | fetch.sh 需要 |
|------|------|--------------|
| WHO DON | JSON OData | `curl` + `jq` 轉 JSONL |
| Taiwan CDC Open Data | CKAN JSON API | `curl` + `jq` 轉 JSONL |
| Singapore data.gov.sg | CKAN JSON API | `curl` + `jq` 轉 JSONL |
| Wikipedia Pageviews | REST JSON API | `curl` + `jq` 轉 JSONL |
| ECDC | RSS 2.0 | `rss_fetch` + `rss_extract_items_jsonl` ✅ |
| US CDC | RSS 2.0 | `rss_fetch` + `rss_extract_items_jsonl` ✅ |

**教訓**：
- `lib/rss.sh` 只處理 RSS/Atom，JSON API 需要另外的處理邏輯
- 考慮新增 `lib/api.sh` 提供 `api_fetch_json` + `api_to_jsonl` 函式
- 在 Layer CLAUDE.md 中明確宣告「資料格式」欄位

---

## 3. 多語言處理錯誤

### 3.1 萃取 prompt 語言不匹配

**錯誤**：用英文 prompt 萃取日文/韓文/中文內容。

**問題**：
- 行政用語、專有名詞可能翻譯不準確
- Claude 可能誤解語境

**教訓**：
- 每個 Layer 的 CLAUDE.md 萃取指令應**以來源語言撰寫示範**
- 或至少提供該語言的專有名詞對照表
- 輸出格式（Markdown）可以統一用英文欄位名，但內容保留原文

---

## 4. 驗證流程缺失

### 4.1 沒有在設計前驗證資料源

**錯誤流程**：
```
設計 Layer 清單 → 開始建設 → 發現資料源不可用 → 重新設計
```

**正確流程**：
```
列出候選資料源 → 逐一驗證可用性 → 記錄到 explored.md → 確認可用後再設計 Layer
```

**教訓**：
- **先探索，後設計**
- 使用 `docs/explored.md` 追蹤所有資料源狀態
- 每個資料源至少要有：實際 URL、格式、語言、更新頻率、最後驗證日期

---

### 4.2 驗證項目不完整

**應驗證的項目 checklist**：

```markdown
## 資料源驗證 Checklist

- [ ] URL 是否回傳 200？
- [ ] Content-Type 是否正確（application/rss+xml, application/json, etc.）？
- [ ] 內容是否非空？
- [ ] 最近一筆資料的日期？（判斷是否仍在更新）
- [ ] 是否需要認證（API key, 註冊, etc.）？
- [ ] 是否有 rate limit？
- [ ] 是否有 IP 限制或 User-Agent 要求？
- [ ] 回傳的欄位是否足夠萃取所需資訊？
- [ ] 是否需要 WebFetch 補充原文？
```

---

## 5. 文件記錄不足

### 5.1 資料源探索結果未及時記錄

**問題**：探索了多個資料源，但沒有統一記錄在 `docs/explored.md`。

**教訓**：
- 每次探索資料源後，**立即**更新 `docs/explored.md`
- 包含「已採用」、「評估中」、「已排除」三個區塊
- 「已排除」要記錄排除原因和日期

---

## 附錄：已知失效的 URL

以下 URL 已確認失效，不要再嘗試：

```
# WHO (已遷移至 JSON API)
https://www.who.int/feeds/entity/don/en/rss.xml          # 404
https://www.who.int/feeds/entity/csr/don/en/rss.xml      # 404
https://www.who.int/feeds/entity/mediacentre/news/en/rss.xml  # 404

# ECDC (錯誤路徑)
https://www.ecdc.europa.eu/en/rss.xml                    # 404

# Japan
https://www.niid.go.jp/                                  # 域名已改為 niid.jihs.go.jp
https://www.forth.go.jp/rss.xml                          # 404
https://www.forth.go.jp/feed/                            # 404

# Korea
https://www.kdca.go.kr/rss.xml                           # 404
https://www.kdca.go.kr/board/rss.es                      # 404

# ProMED
https://www.promedmail.org/rss/                          # 2023-07 關閉
```

---

## 更新紀錄

| 日期 | 更新內容 |
|------|---------|
| 2026-02-02 | 初版建立，記錄資料源探索階段發現的問題 |
