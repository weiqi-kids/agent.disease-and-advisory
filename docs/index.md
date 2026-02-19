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
        dateModified: '2026-02-20T00:00:00Z'
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
    lastReviewed: '2026-02-20'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# EpiAlert 疫情快訊

AI 驅動的全球疫情週報 — 整合 WHO、CDC、ECDC、UKHSA、台灣 CDC 等 7 大官方來源
{: .fs-6 .fw-300 }

**最後更新：2026-02-20 09:00 (UTC+8)**
{: .label .label-green }

[查看 2026-W08 週報](Narrator/weekly_digest/2026-W08-weekly-digest){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[歷史週報](Narrator/weekly_digest/){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## 本週重點
{: .speakable-content }

| 風險 | 疾病/事件 | 地區 | 摘要 | 來源 |
|:----:|-----------|------|------|------|
| 🟡 | 寒冷死亡率報告 | 英國 | 2024-25 冬季 2,544 例死亡與寒流相關，65 歲以上高風險 | [UKHSA](Extractor/uk_ukhsa_updates/) |
| 🟡 | 抗生素抗藥性 | 歐洲 | 沙門氏菌、彎曲桿菌環丙沙星抗藥性高企，碳青黴烯酶檢出上升 | [ECDC](Extractor/ecdc_cdtr/) |
| 🟢 | RSV 疫苗 PGD | 英國 | 發布呼吸道融合病毒疫苗患者群組指示範本 | [UKHSA](Extractor/uk_ukhsa_updates/) |
| 🟡 | 尼帕病毒疫情 | 印度 | HCID 風險清單更新，西孟加拉邦 1/13 確認爆發 | [UKHSA](Extractor/uk_ukhsa_updates/) |
| 🟢 | 麻疹境外移入 | 台灣 | 今年首例，越南感染，400 名接觸者監測至 2/28 | [TW CDC](Extractor/tw_cdc_alerts/) |
| 🟢 | 百日咳確診 | 台灣 | 今年首例，家庭接觸者監測至 3/4 | [TW CDC](Extractor/tw_cdc_alerts/) |
| 🟢 | 猴痘 Mpox | 全球 | clade Ib/IIb 持續監測，英國維持警戒 | [UKHSA](Extractor/uk_ukhsa_updates/) |

**風險等級說明**：🔴 高風險（PHEIC/大規模爆發）｜🟡 中風險（區域爆發/新興威脅）｜🟢 低風險（散發案例/常規監測）
{: .fs-3 .text-grey-dk-000 }

[查看完整週報分析 →](Narrator/weekly_digest/2026-W08-weekly-digest){: .btn .btn-primary }

---

## 本週統計

| 📊 整合公告 | 🦠 追蹤疾病 | 🌍 涵蓋國家 | 📚 歷史資料 |
|:-----------:|:-----------:|:-----------:|:-----------:|
| **42** 個 | **12** 種 | **28** 個 | **2,450+** 篇 |

---

## 資料來源

整合全球 7 大權威公衛機構的官方資料：

| 來源 | 說明 | 更新頻率 |
|------|------|----------|
| [WHO Disease Outbreak News](Extractor/who_disease_outbreak_news/) | 世界衛生組織疾病爆發新聞 | 不定期 |
| [US CDC HAN](Extractor/us_cdc_han/) | 美國 CDC 健康警報網絡 | 不定期 |
| [US CDC MMWR](Extractor/us_cdc_mmwr/) | 美國 CDC 發病率與死亡率週報 | 每週 |
| [US Travel Health Notices](Extractor/us_travel_health_notices/) | 美國 CDC 旅遊健康通知 | 不定期 |
| [ECDC CDTR](Extractor/ecdc_cdtr/) | 歐洲疾病預防控制中心週報 | 每週 |
| [UK UKHSA](Extractor/uk_ukhsa_updates/) | 英國健康安全局更新 | 不定期 |
| [Taiwan CDC](Extractor/tw_cdc_alerts/) | 台灣疾管署警報 | 不定期 |

[查看所有資料來源](Extractor/){: .btn }

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

[了解更多](about){: .btn .btn-outline } [GitHub](https://github.com/weiqi-kids/agent.disease-and-advisory){: .btn .btn-outline }

---

<div class="ymyl-disclaimer">

**免責聲明**：本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。所有資料來源為 WHO、CDC 等官方機構，EpiAlert 不對資料的即時性或完整性做出保證。

</div>
