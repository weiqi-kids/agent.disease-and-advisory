---
title: 首頁
layout: single
sidebar:
  nav: "sidebar"
seo:
  meta:
    title: 'EpiAlert 疫情快訊 - 全球傳染病情報自動收集與分析'
    description: '自動收集並分析來自 WHO、CDC、ECDC 等全球主要公衛機構的傳染病情報，提供即時疫情追蹤、週報分析與旅遊健康建議。'
  json_ld:
    '@context': 'https://schema.org'
    '@graph':
      - '@type': 'WebPage'
        '@id': 'https://epialert.weiqi.kids#webpage'
        url: 'https://epialert.weiqi.kids'
        name: 'EpiAlert 疫情快訊 - 全球傳染病情報自動收集與分析'
        description: '自動收集並分析來自 WHO、CDC、ECDC 等全球主要公衛機構的傳染病情報'
        inLanguage: 'zh-TW'
        isPartOf:
          '@id': 'https://epialert.weiqi.kids#website'
        datePublished: '2026-02-15'
        dateModified: '2026-02-15'
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
      - '@type': 'Person'
        '@id': 'https://epialert.weiqi.kids/about#person'
        name: 'EpiAlert AI 編輯'
        url: 'https://epialert.weiqi.kids/about'
        description: 'AI 驅動的疫情資訊彙整系統，自動收集並分析來自 WHO、CDC 等官方來源的傳染病情報'
        worksFor:
          '@id': 'https://epialert.weiqi.kids#organization'
        knowsAbout:
          - '傳染病監測'
          - '公共衛生'
          - '疫情分析'
          - '流行病學'
        hasCredential:
          - '@type': 'EducationalOccupationalCredential'
            name: 'AI 輔助醫療資訊系統'
            credentialCategory: 'Automated Health Intelligence System'
        sameAs:
          - 'https://github.com/anthropics/claude-code'
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
      - '@type': 'BreadcrumbList'
        itemListElement:
          - '@type': 'ListItem'
            position: 1
            name: '首頁'
            item: 'https://epialert.weiqi.kids'
      - '@type': 'ItemList'
        '@id': 'https://epialert.weiqi.kids#datasources'
        name: '全球傳染病情報資料來源'
        description: '來自 WHO、US CDC、ECDC、UK UKHSA、Taiwan CDC 的即時疫情資料'
        numberOfItems: 7
        itemListElement:
          - '@type': 'ListItem'
            position: 1
            name: 'WHO Disease Outbreak News'
            description: '世界衛生組織疾病爆發新聞'
          - '@type': 'ListItem'
            position: 2
            name: 'US CDC HAN'
            description: '美國 CDC 健康警報網絡'
          - '@type': 'ListItem'
            position: 3
            name: 'US CDC MMWR'
            description: '美國 CDC 發病率與死亡率週報'
          - '@type': 'ListItem'
            position: 4
            name: 'US Travel Health Notices'
            description: '美國 CDC 旅遊健康通知'
          - '@type': 'ListItem'
            position: 5
            name: 'ECDC CDTR'
            description: '歐洲疾病預防控制中心週報'
          - '@type': 'ListItem'
            position: 6
            name: 'UK UKHSA'
            description: '英國健康安全局更新'
          - '@type': 'ListItem'
            position: 7
            name: 'Taiwan CDC'
            description: '台灣疾管署警報'
  ymyl:
    lastReviewed: '2026-02-15'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本站內容由 AI 自動彙整自 WHO、CDC 等官方來源，僅供參考，不構成醫療建議。如有健康疑慮，請諮詢專業醫療人員。'
---

# EpiAlert 疫情快訊

*全球傳染病情報自動收集與分析*

**最後更新：2026-02-16 05:04 (UTC+8)**

{: .notice--warning}
> **免責聲明**：本系統由自動化程式生成，僅供參考用途。內容基於公開資訊來源，不構成醫療建議、官方政策或專業診斷。使用者應自行驗證資訊並諮詢專業人士。

---

## 本週重點

| 日期 | 事件 | 來源 |
|------|------|------|
| 2/12 | 台灣首例麻疹境外移入（越南） | TW CDC |
| 2/12 | 台灣首例百日咳確診 | TW CDC |
| 2/12 | Mpox clade Ib/IIb 監測更新 | UK UKHSA |
| 2/12 | RSV 疫苗覆蓋率報告（孕婦/老年） | UK UKHSA |

[查看完整週報](/Narrator/weekly_digest/2026-W07-weekly-digest){: .btn .btn--primary .btn--large}
[歷史週報](/Narrator/weekly_digest/){: .btn .btn--info}

---

## 關於

本系統自動收集並分析來自全球主要公衛機構的傳染病情報，包括：

- **WHO** — 世界衛生組織
- **US CDC** — 美國疾病管制與預防中心
- **ECDC** — 歐洲疾病預防管制中心
- **UK UKHSA** — 英國健康安全局
- **Taiwan CDC** — 台灣衛生福利部疾病管制署

[GitHub](https://github.com/weiqi-kids/agent.disease-and-advisory){: .btn .btn--info}

---

## 資料來源

| Layer | 說明 |
|-------|------|
| [WHO Disease Outbreak News](/Extractor/who_disease_outbreak_news/) | 世界衛生組織疾病爆發新聞 |
| [US CDC HAN](/Extractor/us_cdc_han/) | 美國 CDC 健康警報網絡 |
| [US CDC MMWR](/Extractor/us_cdc_mmwr/) | 美國 CDC 發病率與死亡率週報 |
| [US Travel Health Notices](/Extractor/us_travel_health_notices/) | 美國 CDC 旅遊健康通知 |
| [ECDC CDTR](/Extractor/ecdc_cdtr/) | 歐洲疾病預防控制中心週報 |
| [UK UKHSA](/Extractor/uk_ukhsa_updates/) | 英國健康安全局更新 |
| [Taiwan CDC](/Extractor/tw_cdc_alerts/) | 台灣疾管署警報 |

[查看所有資料來源](/Extractor/){: .btn .btn--info}
