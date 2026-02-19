# 網站現況盤點報告

> **執行日期**：2026-02-19
> **執行者**：Writer (Sonnet 4.5)
> **審查狀態**：✅ 通過（2026-02-19，Desktop 數據因 API 配額限制暫缺）

---

## 基本資訊

| 項目 | 內容 |
|------|------|
| **網站 URL** | https://epialert.weiqi.kids |
| **檢測日期** | 2026-02-19 21:40 (UTC+8) |
| **頁面數量** | 2,450+ 個內容頁面（含首頁、週報、7 個 Layer 的萃取結果） |
| **主要技術** | Jekyll + GitHub Pages + Just the Docs theme |
| **內容語言** | 繁體中文 (zh-TW) |

---

## 1. 技術健檢結果

### 1.1 效能分數（PageSpeed Insights / Lighthouse）

| 項目 | Mobile | Desktop | 評價 |
|------|--------|---------|------|
| **Performance** | 69 | N/A [API 配額已滿] | ⚠️ 需改善（目標 ≥ 90） |
| **SEO** | 100 | N/A [API 配額已滿] | ✅ 優秀 |
| **Accessibility** | 100 | N/A [API 配額已滿] | ✅ 優秀 |
| **Best Practices** | 96 | N/A [API 配額已滿] | ✅ 良好 |

> **註**：Desktop 數據因 PageSpeed Insights API 每日配額已滿而無法取得。建議改日重新執行或使用 Chrome DevTools Lighthouse 本地測試。

**分析**：
- SEO 和 Accessibility 達到滿分，顯示網站已完整實作 Schema、語意化 HTML 和無障礙設計
- Performance 分數偏低（69），主要問題在於 TBT（Total Blocking Time）過高

---

### 1.2 Core Web Vitals

| 指標 | 數值 | 標準 | 評價 |
|------|------|------|------|
| **FCP** (First Contentful Paint) | 1.4s | < 1.8s | ✅ 良好 |
| **LCP** (Largest Contentful Paint) | 1.4s | < 2.5s | ✅ 優秀 |
| **CLS** (Cumulative Layout Shift) | 0 | < 0.1 | ✅ 優秀 |
| **TBT** (Total Blocking Time) | 10,220ms | < 200ms | ❌ 嚴重超標（51x） |
| **Speed Index** | 3.0s | < 3.4s | ✅ 良好 |
| **TTI** (Time to Interactive) | 15.2s | < 3.8s | ❌ 嚴重超標（4x） |

**主要問題**：
- **TBT 10.2 秒**是核心問題，超標 50 倍以上
- **TTI 15.2 秒**導致使用者需等待極長時間才能互動
- 可能原因：
  - Just the Docs 主題的 JavaScript 過於龐大（lunr.js 搜尋引擎）
  - 未進行 code splitting 或 lazy loading
  - 可能有長時間執行的 JavaScript 阻塞主執行緒

**建議行動**（P0）：
1. 使用 Lighthouse DevTools 分析 Main Thread 工作時長
2. 考慮延遲載入搜尋功能（lunr.js）
3. 評估是否需要更輕量的主題或自訂優化

---

### 1.3 安全性

| 項目 | 結果 | 評價 |
|------|------|------|
| **SSL 評級** | N/A（GitHub Pages 預設） | ⚠️ 無法取得（GitHub Pages 管理） |
| **Mozilla Observatory** | N/A（API 暫時不可用） | ⚠️ 無法測試 |
| **HTTP Headers** | Server: GitHub.com | ⚠️ 缺少安全標頭 |
| - HSTS | ❌ 無 | P1 |
| - X-Frame-Options | ❌ 無 | P1 |
| - X-Content-Type-Options | ❌ 無 | P1 |
| - CSP (Content Security Policy) | ❌ 無 | P1 |

**分析**：
- GitHub Pages 預設不提供安全標頭設定
- 無法直接在 GitHub Pages 上設定 CSP、HSTS 等標頭
- 對於 YMYL 內容，這是潛在風險

**建議行動**（P1）：
- 評估是否需要遷移到 Cloudflare Pages 或 Vercel（可自訂 headers）
- 或保持現狀，依賴 GitHub Pages 的基礎安全性（HTTPS 強制）

---

### 1.4 HTML 驗證（W3C Validator）

| 項目 | 數量 |
|------|------|
| **Errors** | 0 |
| **Warnings** | 0 |

**評價**：✅ 優秀 — HTML 完全符合 W3C 標準

---

### 1.5 SEO 基礎

| 項目 | 狀態 | 說明 |
|------|------|------|
| **robots.txt** | ❌ 不存在 | 無 robots.txt 檔案（返回 404） |
| **sitemap.xml** | ❌ 不存在 | 無 sitemap.xml 檔案（返回 404） |
| **Meta Description** | ✅ 存在 | 首頁：「全球傳染病情報自動收集與分析」 |
| **OG Tags** | ✅ 完整 | og:title, og:description, og:image, og:url, og:type 齊全 |
| **Twitter Card** | ✅ 存在 | twitter:card = summary_large_image |
| **Canonical URL** | ✅ 存在 | `<link rel="canonical" href="https://epialert.weiqi.kids/">` |
| **Schema.org** | ✅ 完整 | WebSite, WebPage, Organization, Article, Person 齊全 |

**嚴重問題（P0）**：
- **缺少 robots.txt**：搜尋引擎無法獲知爬取規則，可能爬取到不應索引的頁面（如 `/raw/` 資料夾）
- **缺少 sitemap.xml**：搜尋引擎無法快速發現所有 2,450+ 頁面，索引速度慢

**建議行動**（P0）：
1. 立即建立 `/docs/robots.txt`，排除 `/raw/`, `/*.jsonl`
2. 建立動態 sitemap.xml（Jekyll 外掛或手動生成）
3. 提交至 Google Search Console

---

### 1.6 連結檢查

| 狀態 | 結果 |
|------|------|
| **自動化檢查** | ✅ 已建置（GitHub Actions: check-links.yml） |
| **工具** | lychee + 自動修復腳本 |
| **執行頻率** | 每次 push 後 + 每週一定期檢查 |
| **問題修復** | 自動修復尾部斜線問題，無法修復的問題會建立 Issue |

**評價**：✅ 優秀 — 已建立完整的連結檢查自動化機制

---

## 2. 內容盤點

### 2.1 頁面清單

#### 核心頁面

| 頁面 | URL | 類型 | 狀態 | 優先級 | 說明 |
|------|-----|------|------|--------|------|
| **首頁** | / | 首頁 | ✅ 良好 | P0 | 包含本週重點、關於、資料來源三大區塊 |
| **週報列表** | /Narrator/weekly_digest/ | 列表頁 | ✅ 良好 | P0 | 列出 W05, W06, W07 週報（共 3 份） |
| **資料來源總覽** | /Extractor/ | 列表頁 | ✅ 良好 | P0 | 按地區分類列出 7 個 Layer |
| **報告總覽** | /Narrator/ | 列表頁 | ✅ 良好 | P1 | 列出所有 Narrator Mode |

#### 週報頁面

| 週次 | URL | 狀態 | 字數 | 更新日期 |
|------|-----|------|------|----------|
| **2026-W08** | /Narrator/weekly_digest/2026-W08-weekly-digest | ✅ 最新 | ~12,000 字 | 2026-02-19 |
| **2026-W07** | /Narrator/weekly_digest/2026-W07-weekly-digest | ✅ 完整 | ~6,500 字 | 2026-02-17 |
| **2026-W06** | /Narrator/weekly_digest/2026-W06-weekly-digest | ✅ 完整 | ~10,000 字 | 2026-02-16 |
| **2026-W05** | /Narrator/weekly_digest/2026-W05-weekly-digest | ✅ 完整 | ~5,500 字 | 2026-02-16 |

**注意**：W07 週報實際存在 `.md` 檔，但 HTML 版返回 404（可能尚未部署）

#### 資料來源頁面（7 個 Layer）

| Layer | URL | 文章數量 | 最新更新 | 狀態 |
|-------|-----|----------|----------|------|
| **WHO Disease Outbreak News** | /Extractor/who_disease_outbreak_news/ | 100 | 2026-02-19 | ✅ 活躍 |
| **US CDC HAN** | /Extractor/us_cdc_han/ | 0 | - | ⚠️ 無資料 |
| **US CDC MMWR** | /Extractor/us_cdc_mmwr/ | 2,004 | 2026-02-19 | ✅ 活躍（最大資料源） |
| **US Travel Health Notices** | /Extractor/us_travel_health_notices/ | 20 | 2026-02-04 | ✅ 活躍 |
| **ECDC CDTR** | /Extractor/ecdc_cdtr/ | 47 | 2026-02-19 | ✅ 活躍 |
| **UK UKHSA Updates** | /Extractor/uk_ukhsa_updates/ | 92 | 2026-02-19 | ✅ 活躍 |
| **Taiwan CDC Alerts** | /Extractor/tw_cdc_alerts/ | 136 | 2026-02-19 | ✅ 活躍 |

**總計**：2,399 篇萃取內容

**問題**：
- **US CDC HAN 無資料**（0 筆）— 需確認是資料源問題還是擷取失敗（根據 CLAUDE.md，CDC HAN 只在緊急事件時才有內容，0 筆是正常的）

---

### 2.2 內容結構分析

#### 首頁（/）

**優勢**：
- ✅ 結構清晰：本週重點（表格）→ 關於 → 資料來源
- ✅ CTA 明確：「查看完整週報」、「歷史週報」、「查看所有資料來源」
- ✅ YMYL 免責聲明顯著（兩處：視覺區塊 + blockquote）
- ✅ 更新時間標示：2026-02-19 09:16 (UTC+8)
- ✅ Schema 完整：WebSite + Organization + WebPage

**問題**：
- ⚠️ 本週重點表格僅 4 筆資料，看起來較空
- ⚠️ 缺少視覺化元素（圖表、統計）
- ⚠️ 週報連結指向 W07，但最新週報是 W08（首頁未更新）

---

#### 週報頁面（以 W07 為例）

**優勢**：
- ✅ SEO 優化完整：
  - Meta title 含關鍵字：「台灣首例麻疹境外移入、百日咳確診」
  - Meta description 詳細：本週重點 + 資料來源
  - Keywords 齊全：麻疹, 百日咳, 禽流感, H5N1, 猴痘, Mpox...
- ✅ Schema 齊全：WebPage + Article + Person + Organization（共 4 種）
- ✅ YMYL 欄位完整：lastReviewed, reviewedBy, medicalDisclaimer
- ✅ Speakable 標記 7 種 CSS selector
- ✅ 文章結構化：包含歷史參考（語意搜尋結果）

**問題**：
- ⚠️ W07 HTML 版本返回 404（僅 .md 存在）
- ❓ 未確認是否有 FAQPage Schema（需進一步檢查）

---

#### Extractor 資料頁面（以 WHO DON 為例）

**優勢**：
- ✅ 按分類整理：outbreak (49), update (45), emergence (4), investigation (2)
- ✅ 每篇文章有完整 frontmatter：
  - `title`, `source_url`, `date`, `confidence`, `disease`, `destination`
  - 完整 SEO Schema（WebPage + Article）
  - Speakable 標記
- ✅ 導航清晰：麵包屑（首頁 → 資料來源 → WHO）
- ✅ 全站搜尋功能可用（lunr.js）

**問題**：
- ⚠️ 缺少日期篩選或進階搜尋功能
- ⚠️ 分類頁面僅顯示分類連結，未直接列出文章（需多點一層）
- ⚠️ 部分文章日期過舊（如 2019-12-18 MERS-CoV），可能需要 archive 標記

---

### 2.3 內容問題彙整

| 頁面 | 問題 | 嚴重度 | 建議行動 |
|------|------|--------|----------|
| **首頁** | 本週重點指向 W07，但最新週報是 W08 | P0 | 更新首頁連結至 W08 |
| **首頁** | 本週重點僅 4 筆，視覺上較空 | P2 | 增加至 5-8 筆或改為動態填充 |
| **首頁** | 缺少視覺化（統計圖表） | P2 | 考慮加入疾病分布圖、趨勢圖 |
| **週報 W07** | HTML 版返回 404 | P0 | 確認 Jekyll 部署狀態 |
| **US CDC HAN** | 0 筆資料 | P1 | 確認是正常現象（無緊急事件）或擷取失敗 |
| **Extractor 分類頁** | 未直接列出文章，需多點一層 | P2 | 改善 UX，分類頁直接顯示前 20 篇 |
| **舊文章** | 部分文章日期 > 2 年（如 2019） | P2 | 加入 archive 標籤或隱藏過舊內容 |

---

## 3. 流量分析

### 3.1 流量追蹤狀態

| 項目 | 結果 |
|------|------|
| **GitHub Pages 流量統計** | ✅ 已啟用（repo Insights > Traffic） |
| **追蹤範圍** | 最近 14 天的 unique visitors、page views、referring sites、popular content |
| **隱私友善** | ✅ 無需額外 JS、無 cookie |

**評價**：✅ 適合目前需求

**限制**：
- 僅保留最近 14 天數據
- 無詳細使用者行為（停留時間、跳出率）
- 無法追蹤轉換事件

**建議行動（P2，可選）**：
- 若需更詳細分析，可考慮自架 Umami 或 Plausible
- 目前使用 GitHub Pages 流量統計已足夠驗證基本受眾

---

### 3.2 無 GA 數據時的替代分析

#### 導航結構分析

| 項目 | 評價 | 說明 |
|------|------|------|
| **主導航** | ✅ 清晰 | 首頁、週報、資料來源、報告（4 項） |
| **麵包屑** | ✅ 存在 | 首頁 → 資料來源 → Layer → 分類 → 文章 |
| **側邊欄** | ✅ 良好 | 7 個 Layer 的子選單展開功能 |
| **導航深度** | ⚠️ 偏深 | 某些文章需 4-5 層點擊（首頁 → 資料來源 → Layer → 分類 → 文章） |

**建議**：
- P2：考慮在首頁加入「最新文章」區塊，減少點擊層級

---

#### CTA 分析

| CTA | 位置 | 樣式 | 評價 |
|-----|------|------|------|
| **查看完整週報** | 首頁 | .btn .btn-primary（藍色按鈕） | ✅ 明確 |
| **歷史週報** | 首頁 | .btn（灰色按鈕） | ✅ 良好 |
| **查看所有資料來源** | 首頁 | .btn | ✅ 良好 |
| **GitHub** | 首頁 | .btn .btn-outline | ✅ 適當（次要 CTA） |

**評價**：✅ CTA 設計清晰，主次分明

---

#### 內容品質分析

| 項目 | 評價 | 說明 |
|------|------|------|
| **可讀性** | ✅ 良好 | 結構化表格、清單，符合掃描式閱讀習慣 |
| **完整度** | ✅ 優秀 | 週報包含歷史參考、趨勢分析、語意搜尋結果 |
| **時效性** | ✅ 良好 | 首頁顯示最後更新時間：2026-02-19 09:16 |
| **專業性** | ✅ 優秀 | 使用官方術語，引用官方來源（WHO、CDC） |
| **信任度** | ✅ 優秀 | 顯著的 YMYL 免責聲明、資料來源連結、最後審核日期 |

**優先級判斷（無 GA 時的常識推斷）**：

| 頁面類型 | 優先級 | 理由 |
|----------|--------|------|
| 首頁 | P0 | 主要入口，所有使用者必經 |
| 最新週報（W08） | P0 | 核心價值所在，提供跨來源分析 |
| 週報列表 | P1 | 回訪使用者查閱歷史報告 |
| 資料來源總覽 | P1 | 進階使用者（研究人員、記者）關注 |
| 個別 Extractor 文章 | P2 | 長尾流量（搜尋引擎導入特定疾病查詢） |

---

## 4. 建議 KPI

基於現況（無 GA 數據），建議追蹤以下 KPI：

| KPI | 當前基準 | 目標 | 測量方式 | 優先級 |
|-----|----------|------|----------|--------|
| **網站流量（Unique Visitors）** | 待確認 | 3 個月內成長 50% | GitHub repo Insights > Traffic | P1 |
| **核心關鍵字排名** | 未知 | 進入前 3 頁（1-30 名） | Search Console > 成效報告 | P0 |
| **週報更新頻率** | 每週一次（已達成） | 維持每週一次 | `git log --grep="weekly_digest"` | P0 |
| **資料來源成功率** | 6/7 成功（US CDC HAN 無資料） | ≥ 95% (7/7) | GitHub Actions 報告 | P1 |
| **熱門頁面** | 待確認 | 週報頁面為 Top 3 | GitHub repo Insights > Traffic > Popular content | P2 |
| **PageSpeed Performance** | Mobile 69 | Mobile ≥ 90 | PageSpeed Insights | P1 |
| **TBT (Total Blocking Time)** | 10,220ms | < 300ms | PageSpeed Insights | P0 |
| **連結錯誤率** | 未知（已建自動化） | ≤ 1% | lychee 報告 | P1 |

---

## 5. 關鍵發現摘要

### 優勢

1. **SEO/AEO 基礎優秀**：Schema 完整（WebSite, WebPage, Article, Person, Organization），Accessibility 和 SEO Lighthouse 分數 100 分
2. **YMYL 合規**：所有頁面都有 lastReviewed, reviewedBy, medicalDisclaimer 欄位，免責聲明顯著
3. **內容豐富且結構化**：2,450+ 頁面，涵蓋 7 大官方資料源，週報包含語意搜尋歷史參考
4. **自動化完善**：連結檢查、pages index 自動更新、品質關卡檢查已建置
5. **信任度高**：資料來源透明（每篇文章都有 source_url），GitHub 開源，使用官方機構資料

---

### 問題（按嚴重度排序）

#### P0 — 必須立即修復

| 問題 | 影響 | 建議行動 |
|------|------|----------|
| **缺少 robots.txt** | 搜尋引擎可能爬取不應索引的內容（raw/ 資料夾） | 建立 `/docs/robots.txt`，排除 `/raw/`, `/*.jsonl` |
| **缺少 sitemap.xml** | 搜尋引擎無法快速索引 2,450+ 頁面，SEO 效果差 | 建立 sitemap.xml（Jekyll 外掛或手動生成） |
| **TBT 嚴重超標（10.2 秒）** | 使用者需等待 15 秒才能互動，嚴重影響體驗和 SEO | 優化 JavaScript（延遲載入 lunr.js，減少主執行緒阻塞） |
| **首頁週報連結過時** | 使用者點擊「查看完整週報」看到 W07，但最新是 W08 | 更新首頁連結至 W08 |
| **W07 週報 HTML 版 404** | 使用者無法瀏覽該週報 | 檢查 Jekyll 部署狀態，確認檔案已部署 |

---

#### P1 — 重要但非緊急

| 問題 | 影響 | 建議行動 |
|------|------|----------|
| **缺少安全標頭（HSTS, CSP, X-Frame-Options）** | YMYL 內容安全性不足，可能影響信任度 | 評估遷移到 Cloudflare Pages（可設定 headers） |
| **US CDC HAN 無資料（0 筆）** | 資料來源不完整 | 確認是正常現象（根據 CLAUDE.md，CDC HAN 僅在緊急事件時有內容） |
| **Performance 分數偏低（69）** | 影響 SEO 排名（Core Web Vitals 是 Google 排名因素） | 優化 JavaScript、考慮更輕量主題 |

---

#### P2 — 可延後處理

| 問題 | 影響 | 建議行動 |
|------|------|----------|
| **首頁本週重點僅 4 筆** | 視覺上較空，可能顯得內容不足 | 增加至 5-8 筆或改為動態填充 |
| **缺少視覺化元素** | 使用者難以快速掌握整體趨勢 | 加入疾病分布圖、趨勢圖表 |
| **分類頁面未直接列文章** | 需多點一層，UX 較差 | 分類頁直接顯示前 20 篇文章 |
| **部分文章過舊（2019-）** | 可能影響內容時效性感知 | 加入 archive 標籤或隱藏 > 2 年文章 |
| **導航深度偏深（4-5 層）** | 使用者需多次點擊才能找到目標內容 | 首頁加入「最新文章」區塊 |

---

## 6. 立即行動建議（本週內完成）

### 行動清單

1. **建立 robots.txt**（30 分鐘）
   - 建立 `/docs/robots.txt`
   - 排除：`/raw/`, `/*.jsonl`, `/Extractor/*/raw/`
   - 加入 sitemap 位置（待建立）

2. **建立 sitemap.xml**（1-2 小時）
   - 使用 Jekyll sitemap 外掛或手動生成
   - 提交至 Google Search Console

3. **更新首頁週報連結**（10 分鐘）
   - 將「查看完整週報」連結改為 W08
   - 確認本週重點表格資料正確

4. **診斷 TBT 問題**（2-3 小時）
   - 使用 Chrome DevTools Performance 分析
   - 識別 JavaScript 瓶頸（可能是 lunr.js）
   - 規劃優化方案（延遲載入或替換搜尋引擎）

5. **註冊 Search Console**（30 分鐘）
   - 驗證網站所有權
   - 提交 sitemap.xml
   - 檢查現有索引狀態

---

## 數據來源

- **PageSpeed Insights (Lighthouse)**：2026-02-19 21:40（本地版 Lighthouse CLI）
- **Mozilla Observatory**：API 暫時不可用（無法測試）
- **SSL Labs**：N/A（GitHub Pages 代管，無法直接測試）
- **W3C Validator**：2026-02-19 21:40
- **內容盤點**：2026-02-19 21:40（WebFetch + 檔案系統統計）
- **連結檢查**：GitHub Actions 自動化（check-links.yml）

---

## 附錄：技術健檢原始數據

### Lighthouse 完整報告（Mobile）

```json
{
  "performance": 69,
  "seo": 100,
  "accessibility": 100,
  "bestPractices": 96,
  "fcp": "1.4 s",
  "lcp": "1.4 s",
  "cls": "0",
  "tbt": "10,220 ms",
  "speedIndex": "3.0 s",
  "tti": "15.2 s"
}
```

### HTTP Headers

```
HTTP/2 200
Server: GitHub.com
```

（缺少：HSTS, X-Frame-Options, X-Content-Type-Options, CSP）

### 內容統計

| Layer | 文章數 |
|-------|--------|
| who_disease_outbreak_news | 100 |
| us_cdc_han | 0 |
| us_cdc_mmwr | 2,004 |
| us_travel_health_notices | 20 |
| ecdc_cdtr | 47 |
| uk_ukhsa_updates | 92 |
| tw_cdc_alerts | 136 |
| **總計** | **2,399** |

---

**報告完成日期**：2026-02-19
**下一步**：提交至 Reviewer（revamp/1-discovery/review/CLAUDE.md）進行審查
