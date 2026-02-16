---
title: 資料來源
layout: single
sidebar:
  nav: "sidebar"
seo:
  meta:
    title: '資料來源 - EpiAlert 疫情快訊'
    description: '收集來自 WHO、US CDC、ECDC、UK UKHSA、Taiwan CDC 等全球主要公衛機構的傳染病情報，涵蓋疾病爆發新聞、健康警報、監測報告與旅遊健康通知。'
  json_ld:
    '@context': 'https://schema.org'
    '@graph':
      - '@type': 'WebPage'
        '@id': 'https://epialert.weiqi.kids/Extractor/#webpage'
        url: 'https://epialert.weiqi.kids/Extractor/'
        name: '資料來源 - EpiAlert 疫情快訊'
        description: '收集來自 WHO、US CDC、ECDC、UK UKHSA、Taiwan CDC 等全球主要公衛機構的傳染病情報'
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
            name: '資料來源'
            item: 'https://epialert.weiqi.kids/Extractor/'
      - '@type': 'ItemList'
        '@id': 'https://epialert.weiqi.kids/Extractor/#datasources'
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
    lastReviewed: '2026-02-16'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本站內容由 AI 自動彙整自 WHO、CDC 等官方來源，僅供參考，不構成醫療建議。如有健康疑慮，請諮詢專業醫療人員。'
---

# 資料來源 (Extractor)

本系統從以下公衛機構收集傳染病情報：

---

## 全球

| Layer | 說明 | 資料類型 |
|-------|------|----------|
| [WHO Disease Outbreak News](who_disease_outbreak_news/) | 世界衛生組織 | 疾病爆發新聞 |

---

## 美國

| Layer | 說明 | 資料類型 |
|-------|------|----------|
| [US CDC HAN](us_cdc_han/) | 健康警報網絡 | 警報、公告、更新 |
| [US CDC MMWR](us_cdc_mmwr/) | 發病率與死亡率週報 | 監測報告、疫情報告 |
| [US Travel Health Notices](us_travel_health_notices/) | 旅遊健康通知 | Level 1-3 警示 |

---

## 歐洲

| Layer | 說明 | 資料類型 |
|-------|------|----------|
| [ECDC CDTR](ecdc_cdtr/) | 歐洲疾病預防控制中心 | 傳染病威脅報告 |
| [UK UKHSA](uk_ukhsa_updates/) | 英國健康安全局 | 健康更新 |

---

## 亞太

| Layer | 說明 | 資料類型 |
|-------|------|----------|
| [Taiwan CDC](tw_cdc_alerts/) | 台灣疾管署 | 疫情警報 |
