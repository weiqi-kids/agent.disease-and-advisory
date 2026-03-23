---
title: 首頁
layout: home
nav_order: 1
seo:
  meta:
    title: 'EpiAlert 疫情快訊 — AI 驅動的全球疫情週報'
    description: '運用 AI 自動彙整 WHO、CDC、ECDC、UKHSA、台灣 CDC 的疫情資訊，提供即時、結構化的傳染病週報與監測分析。免費開源。'
  json_ld:
    '@context': 'https://schema.org'
    '@graph':
      - '@type': 'WebSite'
        '@id': 'https://epialert.weiqi.kids#website'
        url: 'https://epialert.weiqi.kids'
        name: 'EpiAlert 疫情快訊'
        description: 'AI 驅動的全球疫情週報'
        potentialAction:
          '@type': 'SearchAction'
          target: 'https://epialert.weiqi.kids/search?q={search_term_string}'
          query-input: 'required name=search_term_string'
        publisher:
          '@type': 'Organization'
          name: 'EpiAlert'
          url: 'https://epialert.weiqi.kids'
      - '@type': 'WebPage'
        '@id': 'https://epialert.weiqi.kids#webpage'
        url: 'https://epialert.weiqi.kids'
        name: 'EpiAlert 疫情快訊'
        description: '全球傳染病情報自動收集與分析系統'
        inLanguage: 'zh-TW'
        isPartOf:
          '@id': 'https://epialert.weiqi.kids#website'
        primaryImageOfPage:
          '@type': 'ImageObject'
          url: 'https://epialert.weiqi.kids/assets/images/logo.png'
        datePublished: '2026-01-01T00:00:00Z'
        dateModified: '2026-03-23T09:30:00+08:00'
        speakable:
          '@type': 'SpeakableSpecification'
          cssSelector:
            - '.article-summary'
            - '.speakable-content'
            - '.key-takeaway'
            - '.key-answer'
            - '.expert-quote'
            - '.actionable-steps li'
            - '.faq-answer-content'
      - '@type': 'Organization'
        '@id': 'https://epialert.weiqi.kids#organization'
        name: 'EpiAlert 疫情快訊'
        url: 'https://epialert.weiqi.kids'
        logo:
          '@type': 'ImageObject'
          url: 'https://epialert.weiqi.kids/assets/images/logo.png'
          width: 600
          height: 60
        description: '全球傳染病情報自動收集與分析系統'
        sameAs:
          - 'https://github.com/weiqi-kids/agent.disease-and-advisory'
        contactPoint:
          '@type': 'ContactPoint'
          contactType: 'technical support'
          url: 'https://github.com/weiqi-kids/agent.disease-and-advisory/issues'
  ymyl:
    lastReviewed: '2026-03-23'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# EpiAlert 疫情快訊

AI 驅動的全球疫情週報 — 整合 WHO、CDC、ECDC、UKHSA、台灣 CDC 等 7 大官方來源
{: .fs-6 .fw-300 }

**最後更新：2026-03-23 09:30 (UTC+8)**
{: .label .label-green }

[查看 2026-W12 週報](Narrator/weekly_digest/2026-W12){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[歷史週報](Narrator/weekly_digest){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## 本週重點
{: .speakable-content }

<div id="region-filter" style="margin-bottom: 1rem;">
  <span style="margin-right: 0.5rem; color: #666;">篩選地區：</span>
  <button data-region="all" class="btn btn-sm active" style="margin: 0.25rem;">全部</button>
  <button data-region="asia" class="btn btn-sm" style="margin: 0.25rem;">🌏 亞洲</button>
  <button data-region="europe" class="btn btn-sm" style="margin: 0.25rem;">🇪🇺 歐洲</button>
  <button data-region="americas" class="btn btn-sm" style="margin: 0.25rem;">🌎 美洲</button>
  <button data-region="africa" class="btn btn-sm" style="margin: 0.25rem;">🌍 非洲</button>
  <button data-region="global" class="btn btn-sm" style="margin: 0.25rem;">🌐 全球</button>
</div>

<style>
#region-filter button.active { background-color: #7253ed; color: white; }
#region-filter button:hover { opacity: 0.8; }
</style>

<table id="weekly-highlights">
  <thead>
    <tr>
      <th style="text-align:center">風險</th>
      <th>疾病/事件</th>
      <th>地區</th>
      <th>摘要</th>
      <th>來源</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:center">🔴</td>
      <td>腦膜炎球菌感染疫情</td>
      <td>英國肯特郡</td>
      <td>侵襲性腦膜炎球菌感染(MenB)疫情爆發，衛生大臣國會報告，擴大疫苗接種</td>
      <td><a href="Extractor/uk_ukhsa_updates">UKHSA</a></td>
    </tr>
    <tr>
      <td style="text-align:center">🔴</td>
      <td>志賀菌病跨國疫情</td>
      <td>佛得角/歐洲</td>
      <td>佛得角返回旅客逾1,000例志賀菌病及胃腸道感染，涉及EU/EEA、英國、美國</td>
      <td><a href="Extractor/ecdc_cdtr">ECDC</a></td>
    </tr>
    <tr>
      <td style="text-align:center">🟡</td>
      <td>SFTS本土病例</td>
      <td>台灣</td>
      <td>新增1例發熱伴血小板減少綜合症確診，為台灣史上第3例本土個案</td>
      <td><a href="Extractor/tw_cdc_alerts">TW CDC</a></td>
    </tr>
    <tr>
      <td style="text-align:center">🟡</td>
      <td>嬰兒配方奶粉汙染</td>
      <td>歐盟/英國</td>
      <td>六國通報嬰兒食用cereulide汙染配方奶粉後出現症狀，ECDC發布風險評估</td>
      <td><a href="Extractor/ecdc_cdtr">ECDC</a></td>
    </tr>
    <tr>
      <td style="text-align:center">🟡</td>
      <td>COVID-19疫苗政策</td>
      <td>台灣</td>
      <td>4/7起65歲以上長者及免疫不全者可再接種1劑新冠疫苗，公費延長至4/30</td>
      <td><a href="Extractor/tw_cdc_alerts">TW CDC</a></td>
    </tr>
    <tr>
      <td style="text-align:center">🟢</td>
      <td>ECDC CDTR W12/W11</td>
      <td>歐洲</td>
      <td>禽流感、登革熱、基孔肯雅疫苗不良事件、麻疹、猴痘持續監測</td>
      <td><a href="Extractor/ecdc_cdtr">ECDC</a></td>
    </tr>
    <tr>
      <td style="text-align:center">🟢</td>
      <td>免冷藏疫苗突破</td>
      <td>英國/全球</td>
      <td>UKHSA與Stablepharma合作開發免冷藏破傷風/白喉疫苗，對全球疫苗配送具重大意義</td>
      <td><a href="Extractor/uk_ukhsa_updates">UKHSA</a></td>
    </tr>
  </tbody>
</table>

**風險等級說明**：🔴 高風險（PHEIC/大規模爆發）｜🟡 中風險（區域爆發/新興威脅）｜🟢 低風險（散發案例/常規監測）
{: .fs-3 .text-grey-dk-000 }

[查看完整週報分析 →](Narrator/weekly_digest/2026-W12){: .btn .btn-primary }

---

## 本週統計

| 📊 整合公告 | 🦠 追蹤疾病 | 🌍 涵蓋國家 | 📚 歷史資料 |
|:-----------:|:-----------:|:-----------:|:-----------:|
| **66** 個 | **15** 種 | **31** 個 | **2,480+** 篇 |

---

## 資料來源
{: .speakable-content }

<p class="key-answer" data-question="EpiAlert 的資料來源有哪些">整合全球 7 大權威公衛機構的官方資料，確保資訊的權威性與可靠性。</p>

<div class="source-badges" style="display: flex; flex-wrap: wrap; gap: 1rem; justify-content: center; margin: 1.5rem 0;">
  <span style="background: #009edb; color: white; padding: 0.5rem 1rem; border-radius: 4px; font-weight: bold;">🌐 WHO</span>
  <span style="background: #0033a0; color: white; padding: 0.5rem 1rem; border-radius: 4px; font-weight: bold;">🇺🇸 US CDC</span>
  <span style="background: #003399; color: white; padding: 0.5rem 1rem; border-radius: 4px; font-weight: bold;">🇪🇺 ECDC</span>
  <span style="background: #00205B; color: white; padding: 0.5rem 1rem; border-radius: 4px; font-weight: bold;">🇬🇧 UKHSA</span>
  <span style="background: #006241; color: white; padding: 0.5rem 1rem; border-radius: 4px; font-weight: bold;">🇹🇼 台灣 CDC</span>
</div>

| 來源 | 說明 | 更新頻率 |
|------|------|----------|
| [WHO Disease Outbreak News](Extractor/who_disease_outbreak_news) | [世界衛生組織](https://www.who.int)疾病爆發新聞 | 不定期 |
| [US CDC HAN](Extractor/us_cdc_han) | [美國 CDC](https://www.cdc.gov) 健康警報網絡 | 不定期 |
| [US CDC MMWR](Extractor/us_cdc_mmwr) | [美國 CDC](https://www.cdc.gov) 發病率與死亡率週報 | 每週 |
| [US Travel Health Notices](Extractor/us_travel_health_notices) | [美國 CDC](https://www.cdc.gov) 旅遊健康通知 | 不定期 |
| [ECDC CDTR](Extractor/ecdc_cdtr) | [歐洲疾病預防控制中心](https://www.ecdc.europa.eu)週報 | 每週 |
| [UK UKHSA](Extractor/uk_ukhsa_updates) | [英國健康安全局](https://www.gov.uk/government/organisations/uk-health-security-agency)更新 | 不定期 |
| [Taiwan CDC](Extractor/tw_cdc_alerts) | [台灣疾管署](https://www.cdc.gov.tw)警報 | 不定期 |

[查看所有資料來源](Extractor){: .btn }

---

## 關於 EpiAlert
{: .speakable-content }

<p class="key-answer" data-question="EpiAlert 是什麼">EpiAlert 是 AI 驅動的全球疫情週報系統，運用 AI 技術自動彙整 WHO、CDC、ECDC、UKHSA、台灣 CDC 等 7 大官方來源的疫情資訊，每週產出結構化分析報告。</p>

| 項目 | EpiAlert | ProMED | HealthMap |
|------|----------|--------|-----------|
| 定位 | AI 驅動週報 | 專家策展快報 | 即時地圖 |
| 更新頻率 | 每週 | 每日多次 | 即時 |
| 資料來源 | 7 大官方來源 | 多元含非官方 | 多元含新聞 |
| 語意搜尋 | ✅ | ❌ | ❌ |
| 開源透明 | ✅ | ❌ | ❌ |

[了解更多](about){: .btn .btn-outline } [GitHub](https://github.com/weiqi-kids/agent.disease-and-advisory){: .btn .btn-outline } [RSS 訂閱](feed.xml){: .btn .btn-outline }

---

## 快速連結

| 功能 | 說明 |
|------|------|
| [🔍 語意搜尋](search/semantic) | 使用 AI 搜尋 2,450+ 篇歷史疫情資料 |
| [🦠 疾病專頁](disease) | 查看各類傳染病的背景資訊與疫情追蹤 |
| [📧 訂閱週報](subscribe) | Email 或 RSS 訂閱，每週收到疫情摘要 |
| [📖 術語解釋](glossary) | 疫情相關專業術語中英對照 |

---

<div class="ymyl-disclaimer">

**免責聲明**：本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。所有資料來源為 WHO、CDC 等官方機構，EpiAlert 不對資料的即時性或完整性做出保證。

</div>
