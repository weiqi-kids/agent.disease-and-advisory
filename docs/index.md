---
title: 首頁
layout: home
nav_order: 1
---

# 傳染病情報分析系統

Disease Intelligence System
{: .fs-6 .fw-300 }

**最後更新：2026-02-09 10:37 (UTC+8)**
{: .label .label-green }

> **免責聲明**：本系統由自動化程式生成，僅供參考用途。內容基於公開資訊來源，不構成醫療建議、官方政策或專業診斷。使用者應自行驗證資訊並諮詢專業人士。

---

## 週報

最新傳染病威脅週報，綜合分析全球疫情動態。

[最新週報]({{ site.baseurl }}/Narrator/weekly_digest/2026-W06-weekly-digest){: .btn .btn-primary }
[查看所有週報]({{ site.baseurl }}/Narrator/weekly_digest/){: .btn }

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

---

## 關於

本系統自動收集並分析來自全球主要公衛機構的傳染病情報，包括：

- **WHO** — 世界衛生組織
- **US CDC** — 美國疾病管制與預防中心
- **ECDC** — 歐洲疾病預防管制中心
- **UK UKHSA** — 英國健康安全局
- **Taiwan CDC** — 台灣衛生福利部疾病管制署

[GitHub](https://github.com/weiqi-kids/agent.disease-and-advisory){: .btn .btn-outline }
