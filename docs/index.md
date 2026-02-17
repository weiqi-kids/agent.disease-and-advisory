---
title: 首頁
layout: home
nav_order: 1
seo:
  meta:
    title: 'EpiAlert 疫情快訊 - 全球傳染病情報自動收集與分析'
    description: '自動收集並分析 WHO、CDC、ECDC、UKHSA 等全球公衛機構的傳染病情報，提供麻疹、百日咳、RSV、禽流感等疫情即時監測與週報分析。'
  json_ld:
    '@context': 'https://schema.org'
    '@graph':
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
        dateModified: '2026-02-18T00:00:00Z'
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
          - 'https://github.com/anthropics/claude-code'
        contactPoint:
          '@type': 'ContactPoint'
          contactType: 'technical support'
          url: 'https://github.com/anthropics/claude-code/issues'
  ymyl:
    lastReviewed: '2026-02-18'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本系統由自動化程式生成，僅供參考用途。內容基於公開資訊來源，不構成醫療建議、官方政策或專業診斷。使用者應自行驗證資訊並諮詢專業人士。'
---

# EpiAlert 疫情快訊

全球傳染病情報自動收集與分析
{: .fs-6 .fw-300 }

**最後更新：2026-02-18 07:26 (UTC+8)**
{: .label .label-green }

<div class="ymyl-disclaimer">
本站內容由 AI 自動彙整自 WHO、CDC 等官方來源，僅供參考，不構成醫療建議。如有健康疑慮，請諮詢專業醫療人員。
</div>

> **免責聲明**：本系統由自動化程式生成，僅供參考用途。內容基於公開資訊來源，不構成醫療建議、官方政策或專業診斷。使用者應自行驗證資訊並諮詢專業人士。

---

## 本週重點
{: .speakable-content }

| 日期 | 事件 | 來源 |
|------|------|------|
| 2/16 | ECDC-PHAC 國際合作會議 | ECDC |
| 2/16 | 兒童疫苗接種宣傳活動啟動 | UK UKHSA |
| 2/12 | 台灣首例麻疹境外移入（越南） | TW CDC |
| 2/12 | 台灣首例百日咳確診 | TW CDC |

[查看完整週報](Narrator/weekly_digest/2026-W07-weekly-digest){: .btn .btn-primary }
[歷史週報](Narrator/weekly_digest/){: .btn }

---

## 關於
{: .speakable-content }

<p class="key-answer" data-question="EpiAlert 是什麼">EpiAlert 是全球傳染病情報自動收集與分析系統，自動收集並分析來自 WHO、CDC、ECDC、UKHSA 等全球主要公衛機構的傳染病情報。</p>

本系統自動收集並分析來自全球主要公衛機構的傳染病情報，包括：

- **WHO** — 世界衛生組織
- **US CDC** — 美國疾病管制與預防中心
- **ECDC** — 歐洲疾病預防管制中心
- **UK UKHSA** — 英國健康安全局
- **Taiwan CDC** — 台灣衛生福利部疾病管制署

[GitHub](https://github.com/weiqi-kids/agent.disease-and-advisory){: .btn .btn-outline }

---

## 資料來源

| Layer | 說明 |
|-------|------|
| [WHO Disease Outbreak News](Extractor/who_disease_outbreak_news/) | 世界衛生組織疾病爆發新聞 |
| [US CDC HAN](Extractor/us_cdc_han/) | 美國 CDC 健康警報網絡 |
| [US CDC MMWR](Extractor/us_cdc_mmwr/) | 美國 CDC 發病率與死亡率週報 |
| [US Travel Health Notices](Extractor/us_travel_health_notices/) | 美國 CDC 旅遊健康通知 |
| [ECDC CDTR](Extractor/ecdc_cdtr/) | 歐洲疾病預防控制中心週報 |
| [UK UKHSA](Extractor/uk_ukhsa_updates/) | 英國健康安全局更新 |
| [Taiwan CDC](Extractor/tw_cdc_alerts/) | 台灣疾管署警報 |

[查看所有資料來源](Extractor/){: .btn }
