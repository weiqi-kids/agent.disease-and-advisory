---
title: 報告
layout: single
sidebar:
  nav: "sidebar"
seo:
  meta:
    title: '報告 - EpiAlert 疫情快訊'
    description: '系統自動產出的傳染病威脅綜合分析報告，整合 WHO、CDC、ECDC 等多個來源，提供趨勢比較、區域分析與旅遊建議。'
  json_ld:
    '@context': 'https://schema.org'
    '@graph':
      - '@type': 'WebPage'
        '@id': 'https://epialert.weiqi.kids/Narrator/#webpage'
        url: 'https://epialert.weiqi.kids/Narrator/'
        name: '報告 - EpiAlert 疫情快訊'
        description: '系統自動產出的傳染病威脅綜合分析報告，整合多個官方來源'
        inLanguage: 'zh-TW'
        isPartOf:
          '@id': 'https://epialert.weiqi.kids#website'
        datePublished: '2026-02-16'
        dateModified: '2026-02-16'
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
          - '@type': 'ListItem'
            position: 2
            name: '報告'
            item: 'https://epialert.weiqi.kids/Narrator/'
      - '@type': 'ItemList'
        '@id': 'https://epialert.weiqi.kids/Narrator/#reporttypes'
        name: '疫情分析報告類型'
        description: '跨來源綜合分析報告'
        numberOfItems: 1
        itemListElement:
          - '@type': 'ListItem'
            position: 1
            name: '週報摘要'
            description: '每週傳染病威脅綜合分析，含趨勢比較與區域分析'
  ymyl:
    lastReviewed: '2026-02-16'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本站內容由 AI 自動彙整自 WHO、CDC 等官方來源，僅供參考，不構成醫療建議。如有健康疑慮，請諮詢專業醫療人員。'
---

# 報告 (Narrator)

系統自動產出的綜合分析報告。

---

## 可用報告

| 報告類型 | 說明 | 頻率 |
|----------|------|------|
| [週報摘要](weekly_digest) | 每週傳染病威脅綜合分析 | 每週 |

---

## 報告特色

- **跨來源綜合** — 整合 WHO、CDC、ECDC 等多個來源
- **趨勢比較** — 與上週比較，標示新增、升級、持續、解除
- **區域分析** — 依歐洲、亞太、美洲分區
- **旅遊建議** — 整合旅遊健康警示
