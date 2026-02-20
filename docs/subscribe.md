---
title: 訂閱週報
layout: default
nav_order: 6
seo:
  meta:
    title: '訂閱 EpiAlert 疫情週報 — 每週收到全球疫情摘要'
    description: '免費訂閱 EpiAlert 疫情週報，每週一收到全球疫情摘要，不遺漏重要疫情資訊。整合 WHO、CDC、ECDC 等 7 大官方來源。'
  ymyl:
    lastReviewed: '2026-02-20'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# 訂閱週報
{: .speakable-content }

<p class="key-answer" data-question="如何訂閱 EpiAlert 週報">您可以透過 Email 訂閱或 RSS 訂閱方式接收 EpiAlert 週報。Email 訂閱每週一發送，RSS 可透過 Feedly 等閱讀器訂閱。</p>

每週收到全球疫情摘要，不遺漏重要資訊。

---

## Email 訂閱

<div class="subscribe-container" style="background: #f6f8fa; padding: 1.5rem; border-radius: 8px; margin: 1rem 0;">

<div style="background: #fff3cd; padding: 1rem; border-radius: 4px; margin-bottom: 1rem;">
  <strong>🚧 Email 訂閱服務開發中</strong><br>
  我們正在整合 Email 訂閱服務。目前請使用 RSS 訂閱或定期訪問網站。
</div>

<form id="subscribe-form" onsubmit="handleSubscribe(event)">
  <div style="margin-bottom: 1rem;">
    <label for="email" style="display: block; margin-bottom: 0.5rem; font-weight: bold;">Email 地址</label>
    <input type="email" id="email" name="email" placeholder="your@email.com" required style="width: 100%; padding: 0.75rem; font-size: 1rem; border: 1px solid #ddd; border-radius: 4px;">
  </div>

  <div style="margin-bottom: 1rem;">
    <label style="display: flex; align-items: flex-start; gap: 0.5rem;">
      <input type="checkbox" name="consent" required style="margin-top: 0.25rem;">
      <span style="font-size: 0.9rem;">我同意接收 EpiAlert 週報，並了解可隨時取消訂閱。</span>
    </label>
  </div>

  <button type="submit" class="btn btn-primary" disabled>
    📧 訂閱週報（開發中）
  </button>
</form>

</div>

<script>
function handleSubscribe(event) {
  event.preventDefault();
  alert('Email 訂閱服務開發中，請暫時使用 RSS 訂閱。感謝您的耐心等待！');
}
</script>

---

## RSS 訂閱

透過 RSS 閱讀器訂閱，即時獲取最新週報。

<div style="background: #d4edda; padding: 1rem; border-radius: 4px; margin: 1rem 0;">

**✅ RSS 訂閱已上線**

</div>

### 訂閱連結

<a href="../feed.xml" class="btn btn-primary" target="_blank">
  📡 RSS Feed
</a>

**Feed URL**: `https://epialert.weiqi.kids/feed.xml`

### 推薦 RSS 閱讀器

| 平台 | 推薦閱讀器 | 說明 |
|------|------------|------|
| 跨平台 | [Feedly](https://feedly.com) | 最受歡迎的 RSS 閱讀器 |
| 跨平台 | [Inoreader](https://www.inoreader.com) | 功能強大，免費版夠用 |
| macOS/iOS | [NetNewsWire](https://netnewswire.com) | 免費開源，原生體驗 |
| Android | [FeedMe](https://play.google.com/store/apps/details?id=com.seazon.feedme) | 乾淨介面 |
| 自架 | [Miniflux](https://miniflux.app) | 開源自託管方案 |

### Feedly 一鍵訂閱

<a href="https://feedly.com/i/subscription/feed%2Fhttps%3A%2F%2Fepialert.weiqi.kids%2Ffeed.xml" target="_blank" class="btn btn-outline">
  用 Feedly 訂閱
</a>

---

## 訂閱內容

| 項目 | 說明 |
|------|------|
| **發送頻率** | 每週一次（週一早上） |
| **內容** | 本週疫情摘要、風險等級、行動建議 |
| **格式** | 簡潔文字版 + 網站連結 |
| **語言** | 繁體中文（英文版開發中） |

### 範例內容

```
EpiAlert 疫情週報 2026-W08

本週重點：
🟡 寒冷死亡率報告 — 英國 2,544 例死亡
🟡 抗生素抗藥性 — 歐洲沙門氏菌監測
🟢 麻疹境外移入 — 台灣首例

完整報告：https://epialert.weiqi.kids/...
```

---

## 其他訂閱方式

### GitHub Watch

如果您使用 GitHub，可以 Watch 我們的 Repository：

<a href="https://github.com/weiqi-kids/agent.disease-and-advisory" target="_blank" class="btn btn-outline">
  GitHub Repository
</a>

### 社群媒體

<div style="background: #f6f8fa; padding: 1rem; border-radius: 4px; margin: 1rem 0;">

**📢 社群媒體帳號規劃中**

未來將提供 Twitter/X、LINE 官方帳號等訂閱方式。

</div>

---

## 隱私保護

- 我們不會將您的 Email 分享給第三方
- 您可隨時取消訂閱
- 訂閱資料僅用於發送週報
- 詳見 [隱私政策](../privacy)（規劃中）

---

## 常見問題

### 為什麼要訂閱？

- **不遺漏重要疫情**：每週自動收到摘要
- **節省時間**：不用每天查看多個網站
- **專業整理**：AI 幫您篩選最重要的資訊

### 多久會收到一封信？

每週一次，週一早上發送。緊急疫情可能會有額外通知。

### 如何取消訂閱？

每封信底部都有取消訂閱連結，一鍵取消。

---

<div class="ymyl-disclaimer">

**免責聲明**：本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。

</div>
