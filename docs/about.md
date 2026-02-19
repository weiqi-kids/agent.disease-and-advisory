---
title: 關於
layout: default
nav_order: 2
seo:
  meta:
    title: '關於 EpiAlert — 開源、AI 驅動的全球疫情監測平台'
    description: 'EpiAlert 是開源、非營利的疫情監測專案，運用 AI 自動彙整 WHO、CDC、ECDC 等 7 大官方來源。程式碼公開於 GitHub。'
  json_ld:
    '@context': 'https://schema.org'
    '@type': 'AboutPage'
    '@id': 'https://epialert.weiqi.kids/about#aboutpage'
    url: 'https://epialert.weiqi.kids/about'
    name: '關於 EpiAlert'
    description: '開源、AI 驅動的全球疫情監測平台'
    inLanguage: 'zh-TW'
    isPartOf:
      '@id': 'https://epialert.weiqi.kids#website'
    mainEntity:
      '@type': 'Organization'
      '@id': 'https://epialert.weiqi.kids#organization'
  ymyl:
    lastReviewed: '2026-02-20'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# 關於 EpiAlert

EpiAlert 疫情快訊是一個**開源、非營利**的全球傳染病監測平台，運用 AI 技術自動彙整 WHO、CDC、ECDC 等 7 大官方來源的疫情資訊，每週產出結構化的疫情週報。

---

## 我們的使命

讓關心公共衛生的民眾、專業人士和決策者，能在單一平台快速掌握全球疫情動態，做出知情決策。

我們相信：

- **資訊透明**：所有資料來源公開，處理邏輯可追溯
- **普及可及**：免費開放，降低資訊落差
- **AI 賦能**：運用 AI 技術提升資訊處理效率

---

## 資料來源與處理流程

### 資料來源

我們整合以下 7 個權威公衛機構的官方資料：

| 來源 | 說明 | 更新頻率 |
|------|------|----------|
| **WHO Disease Outbreak News** | 世界衛生組織疫情爆發新聞 | 不定期 |
| **US CDC Health Alert Network** | 美國 CDC 健康警報 | 不定期 |
| **US CDC MMWR** | 美國 CDC 發病率與死亡率週報 | 每週 |
| **US CDC Travel Health Notices** | 美國 CDC 旅遊健康通知 | 不定期 |
| **ECDC CDTR** | 歐洲傳染病威脅報告 | 每週 |
| **UKHSA Updates** | 英國健康安全局更新 | 不定期 |
| **Taiwan CDC Alerts** | 台灣疾管署警報 | 不定期 |

### 處理流程

```
1. 自動擷取 → 2. AI 萃取 → 3. 向量化儲存 → 4. 週報產出 → 5. 人工審核
```

1. **自動擷取**：每日從各官方來源擷取最新資料
2. **AI 萃取**：使用 Claude (Anthropic) 將非結構化內容轉為結構化資料
3. **向量化儲存**：存入 Qdrant 向量資料庫，支援語意搜尋
4. **週報產出**：每週由 AI 進行跨來源綜合分析，產出週報
5. **人工審核**：重要內容標記 `[REVIEW_NEEDED]`，由人工確認

---

## 技術架構

| 項目 | 技術 |
|------|------|
| **前端** | Jekyll + GitHub Pages + Just the Docs 主題 |
| **AI 模型** | Claude Opus/Sonnet (Anthropic) |
| **向量資料庫** | Qdrant（語意搜尋） |
| **Embedding** | OpenAI text-embedding-3-small |
| **自動化** | Shell Script + GitHub Actions |

---

## 開源與透明

EpiAlert 的所有程式碼皆公開於 GitHub，您可以：

- 查看資料處理邏輯
- 追溯每篇文章的原始來源
- 提交 Issue 或 Pull Request
- Fork 專案建立自己的版本

[GitHub Repository →](https://github.com/weiqi-kids/agent.disease-and-advisory){: .btn .btn-primary }

**授權**：MIT License

---

## 與其他平台的差異

| 項目 | EpiAlert | ProMED | HealthMap | WHO DON |
|------|----------|--------|-----------|---------|
| **定位** | AI 驅動週報 | 專家策展快報 | 即時地圖 | 官方通報 |
| **更新頻率** | 每週 | 每日多次 | 即時（15 分鐘） | 不定期 |
| **資料來源** | 7 大官方來源 | 多元（含非官方） | 多元（含新聞） | WHO 官方 |
| **核心功能** | 週報整合分析 | 即時快報 | 互動地圖 | 官方通報 |
| **語意搜尋** | ✅ | ❌ | ❌ | ❌ |
| **開源透明** | ✅ | ❌ | ❌ | ❌ |
| **免費** | ✅ | ✅ | ✅ | ✅ |

---

## 聯絡我們

- **GitHub Issues**：[提交問題或建議](https://github.com/weiqi-kids/agent.disease-and-advisory/issues)

我們歡迎任何意見回饋、錯誤回報或合作提案。

---

<div class="ymyl-disclaimer">

**免責聲明**：本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。所有資料來源為 WHO、CDC 等官方機構，EpiAlert 不對資料的即時性或完整性做出保證。

</div>
