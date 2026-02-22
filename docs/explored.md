---
title: 疾病監測資料源探索紀錄
layout: single
nav_exclude: true
seo:
  ymyl:
    lastReviewed: '2026-02-22'
    reviewedBy: 'EpiAlert AI 編輯'
---

# 疾病監測資料源探索紀錄

> 最後更新：2026-02-02

---

## 已採用

以下資料源已驗證可用，可直接建立 Layer。

| 資料源 | 類型 | 對應 Layer | 採用日期 | URL | 備註 |
|--------|------|-----------|----------|-----|------|
| WHO Disease Outbreak News | JSON API | `who_disease_outbreak_news` | 2026-02-02 | `https://www.who.int/api/news/diseaseoutbreaknews` | OData v4，舊 RSS 已停用 |
| ECDC CDTR 週報 | RSS | `ecdc_cdtr` | 2026-02-02 | `https://www.ecdc.europa.eu/en/taxonomy/term/1505/feed` | 每週五更新 |
| ECDC 流行病學更新 | RSS | `ecdc_cdtr` | 2026-02-02 | `https://www.ecdc.europa.eu/en/taxonomy/term/1310/feed` | 月/不定期 |
| ECDC 風險評估 | RSS | `ecdc_cdtr` | 2026-02-02 | `https://www.ecdc.europa.eu/en/taxonomy/term/1295/feed` | 不定期 |
| ECDC 新聞公告 | RSS | `ecdc_cdtr` | 2026-02-02 | `https://www.ecdc.europa.eu/en/taxonomy/term/1307/feed` | 每週數次 |
| Taiwan CDC 新聞稿 | RSS | `tw_cdc_alerts` | 2026-02-02 | `https://www.cdc.gov.tw/RSS/RssXml/Hh094B49-DRwe2RR4eFfrQ?type=1` | ZH-TW，每日多次 |
| Taiwan CDC 致醫界通函 | RSS | `tw_cdc_alerts` | 2026-02-02 | `https://www.cdc.gov.tw/RSS/RssXml/khD5i5xbqmYc8zCDhJimNg?type=1` | ZH-TW，每週 |
| Taiwan CDC 傳染病介紹 | RSS | `tw_cdc_alerts` | 2026-02-02 | `https://www.cdc.gov.tw/RSS/RssXml/M8GG46VTKYT2o1VJTKvl7A?type=2` | ZH-TW |
| Taiwan CDC 英文新聞 | RSS | `tw_cdc_alerts` | 2026-02-02 | `https://www.cdc.gov.tw/En/RSS/RssXml/sOn2_m9QgxKqhZ7omgiz1A?type=1` | EN |
| US CDC MMWR | RSS | `us_cdc_mmwr` | 2026-02-02 | `https://tools.cdc.gov/api/v2/resources/media/342778.rss` | 每週五 |
| US CDC HAN | RSS | `us_cdc_han` | 2026-02-02 | `https://tools.cdc.gov/api/v2/resources/media/413690.rss` | 緊急公告 |
| US CDC Travel Notices | RSS | `us_travel_health_notices` | 2026-02-02 | `https://wwwnc.cdc.gov/travel/rss/notices.xml` | 每週數次，含 Level 1/2 |
| US CDC EID 期刊 | RSS | `us_cdc_eid` | 2026-02-02 | `https://wwwnc.cdc.gov/eid/rss/ahead-of-print.xml` | 每週數次 |
| UK UKHSA 全部活動 | Atom | `uk_ukhsa_updates` | 2026-02-02 | `https://www.gov.uk/government/organisations/uk-health-security-agency.atom` | 每日 |
| UK UKHSA 新聞 | Atom | `uk_ukhsa_updates` | 2026-02-02 | `https://www.gov.uk/search/news-and-communications.atom?organisations[]=uk-health-security-agency` | 不定期 |
| UK UKHSA Blog | Atom | `uk_ukhsa_updates` | 2026-02-02 | `https://ukhsa.blog.gov.uk/feed/` | 不定期 |
| Japan MHLW 新着情報 | RSS 1.0 | `jp_mhlw_notices` | 2026-02-02 | `https://www.mhlw.go.jp/stf/news.rdf` | JP |
| Japan MHLW 緊急情報 | RSS 1.0 | `jp_mhlw_notices` | 2026-02-02 | `https://www.mhlw.go.jp/stf/kinkyu.rdf` | JP，最後更新 2023-03 |
| WHO AFRO Emergencies | RSS | `who_afro_emergencies` | 2026-02-02 | `https://www.afro.who.int/rss/emergencies.xml` | 非洲區域 |

---

## 評估中

以下資料源需要進一步評估或開發。

| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 備註 |
|--------|------|-----|------|----------|------|------|
| Taiwan CDC Open Data API | CKAN API | `https://data.cdc.gov.tw/api/3/action/` | ZH/EN | 2026-02-02 | ✅ 可用 | 325+ datasets |
| Taiwan NIDSS | Web Dashboard | `https://nidss.cdc.gov.tw/` | ZH-TW | 2026-02-02 | ⚠️ 需評估 | 即時監測資料 |
| Singapore Weekly Bulletin | JSON API | `https://data.gov.sg/api/action/datastore_search?resource_id=d_ca168b2cb763640d72c4600a68f9909e` | EN | 2026-02-02 | ✅ 可用 | 20,070+ 筆 |
| Japan NIID/JIHS | Web only | `https://www.niid.jihs.go.jp/` | JP | 2026-02-02 | ❌ 無 RSS | 需 HTML scraper |
| Japan IDWR 週報 | PDF/CSV | `https://id-info.jihs.go.jp/surveillance/idwr/` | JP | 2026-02-02 | ❌ 無 RSS | 需 PDF 解析 |
| Japan FORTH | Web only | `https://www.forth.go.jp/` | JP | 2026-02-02 | ❌ 無 RSS | 需 HTML scraper |
| Korea KDCA 보도자료 | Web only | `https://www.kdca.go.kr/board.es?mid=a30402000000&bid=0030` | KR | 2026-02-02 | ❌ 無 RSS | 需 HTML scraper |
| Korea KDCA English | Web only | `https://www.kdca.go.kr/eng/4289/subview.do` | EN | 2026-02-02 | ❌ 無 RSS | 需 HTML scraper |
| Korea PHWR 週報 | PDF | `https://www.phwr.org` | KR/EN | 2026-02-02 | ❌ 僅 email 訂閱 | phwrcdc@korea.kr |
| Korea data.go.kr APIs | JSON/XML | `https://www.data.go.kr` | KR | 2026-02-02 | ⚠️ 需註冊 | COVID/疫苗等 |
| Wikipedia Pageview API | REST API | `https://wikimedia.org/api/rest_v1/metrics/pageviews/` | Multi | 2026-02-02 | ✅ 可用 | 200 req/sec |
| Google Trends (pytrends) | Unofficial | `https://github.com/GeneralMills/pytrends` | Multi | 2026-02-02 | ⚠️ 非官方 | Rate limit 風險 |
| WHO GHO OData | OData API | `https://ghoapi.azureedge.net/api` | EN | 2026-02-02 | ✅ 可用 | 2025 底更新 |
| WHO FluNet | Web Database | `https://www.who.int/tools/flunet` | EN | 2026-02-02 | ✅ 可用 | GISRS 資料 |
| CDC WONDER | XML API | `https://wonder.cdc.gov/` | EN | 2026-02-02 | ✅ 可用 | 需 2 分鐘間隔 |
| Delphi Epidata | REST API | `https://api.delphi.cmu.edu/epidata/` | EN | 2026-02-02 | ✅ 可用 | ILI/COVID/Dengue |
| disease.sh | REST API | `https://disease.sh` | EN | 2026-02-02 | ✅ 可用 | COVID 即時統計 |
| outbreak.info | REST API | `https://api.outbreak.info/` | EN | 2026-02-02 | ✅ 可用 | COVID 專注 |
| GIDEON | REST API | `https://api-doc.gideononline.com/` | EN | 2026-02-02 | ⚠️ 需訂閱 | 機構可能免費 |
| EpiWATCH | Dashboard | `https://www.epiwatch.org/` | Multi | 2026-02-02 | ⚠️ 無公開 API | 46 語言 AI 監測 |
| GPHIN | Membership | `GPHIN-RMISP@phac-aspc.gc.ca` | Multi | 2026-02-02 | ⚠️ 需申請 | 公衛機構專用 |
| ProMED samdesk | Commercial API | `https://api.samdesk.io/` | EN | 2026-02-02 | ⚠️ 付費 | ProMED 替代 |

---

## 已排除

以下資料源已確認不可用或不適合。

| 資料源 | 類型 | 排除原因 | 排除日期 | 重新評估 |
|--------|------|----------|----------|----------|
| WHO RSS (舊版) | RSS | URL 已 404，遷移至 JSON API | 2026-02-02 | 不需要，已有替代 |
| ProMED-mail RSS | RSS | 2023-07 永久關閉 | 2026-02-02 | 考慮 samdesk 付費 API |
| HealthMap Public API | API | 無公開 API，僅 dashboard | 2026-02-02 | 2026-Q3 |
| Japan MHLW Influenza RSS | RSS | 2011 年停更（H1N1 疫情專用） | 2026-02-02 | 不需要 |
| Singapore MOH Newsroom | Web | 403 擋自動存取 | 2026-02-02 | 用 data.gov.sg 替代 |

---

## 已知失效 URL

以下 URL 已確認失效，**請勿使用**：

```
# WHO (已遷移至 JSON API)
https://www.who.int/feeds/entity/don/en/rss.xml
https://www.who.int/feeds/entity/csr/don/en/rss.xml
https://www.who.int/feeds/entity/mediacentre/news/en/rss.xml

# ECDC (錯誤路徑)
https://www.ecdc.europa.eu/en/rss.xml

# Japan (域名變更或無 RSS)
https://www.niid.go.jp/                    # → niid.jihs.go.jp
https://www.forth.go.jp/rss.xml
https://www.forth.go.jp/feed/

# Korea (無 RSS)
https://www.kdca.go.kr/rss.xml
https://www.kdca.go.kr/board/rss.es
https://www.phwr.org/rss.xml

# ProMED (已關閉)
https://www.promedmail.org/rss/
```

---

## 建設優先級建議

### Phase 1 — 立即可建（RSS/API 驗證通過）

1. `who_disease_outbreak_news` — JSON API
2. `ecdc_cdtr` — RSS × 4
3. `tw_cdc_alerts` — RSS × 4
4. `us_cdc_mmwr` — RSS
5. `us_cdc_han` — RSS
6. `us_travel_health_notices` — RSS
7. `uk_ukhsa_updates` — Atom × 3

### Phase 2 — 需少量適配

1. `jp_mhlw_notices` — RSS 1.0（只有厚労省）
2. `sg_moh_updates` — data.gov.sg JSON API
3. `global_signal_pageviews` — Wikipedia REST API

### Phase 3 — 需較大開發

1. `kr_kdca_alerts` — 需 HTML scraper
2. `jp_niid_updates` — 需 HTML scraper
3. `global_signal_trends` — 非官方 API，不穩定
