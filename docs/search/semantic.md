---
title: 語意搜尋
layout: default
nav_order: 5
seo:
  meta:
    title: '語意搜尋 — AI 驅動的疫情歷史資料庫搜尋'
    description: '使用 AI 語意搜尋，快速找到相似歷史疫情案例。涵蓋 WHO、CDC、ECDC、UKHSA、台灣 CDC 的 2,450+ 篇官方資料，支援自然語言查詢。'
  ymyl:
    lastReviewed: '2026-02-20'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# 語意搜尋
{: .speakable-content }

<p class="key-answer" data-question="什麼是語意搜尋">語意搜尋使用 AI 技術理解查詢的意義，而非僅比對關鍵字。這讓您可以用自然語言描述想找的資訊，系統會找出意義相近的歷史疫情記錄。</p>

使用 AI 語意搜尋，快速找到相似歷史疫情案例。

---

## 搜尋介面

<div class="search-container" style="background: #f6f8fa; padding: 1.5rem; border-radius: 8px; margin: 1rem 0;">

<div style="margin-bottom: 1rem;">
  <input type="text" id="semantic-query" placeholder="輸入自然語言查詢，例如：Marburg virus outbreak Africa" style="width: 100%; padding: 0.75rem; font-size: 1rem; border: 1px solid #ddd; border-radius: 4px;">
</div>

<button id="search-btn" class="btn btn-primary" onclick="performSearch()" style="margin-right: 0.5rem;">
  🔍 搜尋
</button>
<button class="btn btn-outline" onclick="clearSearch()">
  清除
</button>

<p id="search-status" style="margin-top: 1rem; color: #666; font-size: 0.9rem;"></p>

</div>

<div id="search-results" style="margin-top: 1rem;"></div>

<script>
function performSearch() {
  var query = document.getElementById('semantic-query').value;
  var statusEl = document.getElementById('search-status');
  var resultsEl = document.getElementById('search-results');

  if (!query.trim()) {
    statusEl.textContent = '請輸入查詢內容';
    return;
  }

  statusEl.innerHTML = '⏳ 搜尋中...（此為展示版本，實際 API 整合開發中）';

  // Demo results - in production this would call the Qdrant API
  setTimeout(function() {
    statusEl.textContent = '找到 5 筆相關結果（展示數據）';
    resultsEl.innerHTML = '<div style="background: #fff3cd; padding: 1rem; border-radius: 4px; margin-bottom: 1rem;">' +
      '<strong>🚧 功能開發中</strong><br>' +
      '語意搜尋 API 整合正在進行中。以下為模擬結果展示。' +
      '</div>' +
      '<table>' +
      '<thead><tr><th>日期</th><th>來源</th><th>標題</th><th>相關性</th></tr></thead>' +
      '<tbody>' +
      '<tr><td>2026-02</td><td>UKHSA</td><td>HCID Risk List Update</td><td>0.85</td></tr>' +
      '<tr><td>2026-01</td><td>WHO DON</td><td>Marburg virus disease - Rwanda</td><td>0.82</td></tr>' +
      '<tr><td>2025-12</td><td>ECDC</td><td>Marburg outbreak response update</td><td>0.78</td></tr>' +
      '<tr><td>2025-10</td><td>WHO DON</td><td>Marburg virus disease - Tanzania</td><td>0.75</td></tr>' +
      '<tr><td>2025-09</td><td>US CDC</td><td>Marburg Travel Health Notice</td><td>0.72</td></tr>' +
      '</tbody></table>';
  }, 1000);
}

function clearSearch() {
  document.getElementById('semantic-query').value = '';
  document.getElementById('search-status').textContent = '';
  document.getElementById('search-results').innerHTML = '';
}
</script>

---

## 範例查詢

點擊以下範例即可快速搜尋：

<div style="display: flex; flex-wrap: wrap; gap: 0.5rem; margin: 1rem 0;">
  <button class="btn btn-sm" onclick="document.getElementById('semantic-query').value='Marburg virus outbreak Africa';performSearch();">Marburg virus outbreak</button>
  <button class="btn btn-sm" onclick="document.getElementById('semantic-query').value='measles outbreak Taiwan 2026';performSearch();">measles outbreak Taiwan</button>
  <button class="btn btn-sm" onclick="document.getElementById('semantic-query').value='H5N1 avian influenza human cases';performSearch();">H5N1 human cases</button>
  <button class="btn btn-sm" onclick="document.getElementById('semantic-query').value='mpox clade Ib outbreak 2025 2026';performSearch();">mpox clade Ib</button>
  <button class="btn btn-sm" onclick="document.getElementById('semantic-query').value='antimicrobial resistance foodborne';performSearch();">antimicrobial resistance</button>
  <button class="btn btn-sm" onclick="document.getElementById('semantic-query').value='RSV vaccine pregnant elderly';performSearch();">RSV vaccine</button>
</div>

---

## 語意搜尋 vs 關鍵字搜尋

| 功能 | 語意搜尋 | 關鍵字搜尋 |
|------|----------|------------|
| **搜尋方式** | 理解查詢意義 | 比對完全符合的字詞 |
| **查詢語言** | 自然語言 | 精確關鍵字 |
| **結果品質** | 找到意義相近的內容 | 可能遺漏同義詞 |
| **適用情境** | 探索性搜尋、找相似案例 | 已知確切名稱 |

### 使用建議

**適合使用語意搜尋**：
- 「亞洲地區的呼吸道疾病疫情」
- 「類似 COVID 的新興傳染病」
- 「疫苗相關的副作用報告」

**適合使用關鍵字搜尋**：
- 特定疾病名稱（如 "H5N1"）
- 特定國家/地區（如 "Taiwan CDC"）
- 特定報告編號

---

## 技術說明
{: .speakable-content }

<p class="key-answer" data-question="EpiAlert 語意搜尋如何運作">EpiAlert 使用 Qdrant 向量資料庫和 OpenAI Embeddings 技術。每篇文章被轉換為 1536 維向量，搜尋時計算查詢與文章的語意相似度，回傳最相關的結果。</p>

### 系統架構

```
使用者查詢
    ↓
OpenAI Embeddings API
    ↓ (轉換為向量)
Qdrant 向量資料庫
    ↓ (相似度搜尋)
排序後的相關結果
```

### 涵蓋資料

| 來源 | 文章數 | 更新頻率 |
|------|--------|----------|
| WHO Disease Outbreak News | 500+ | 不定期 |
| US CDC HAN | 200+ | 不定期 |
| US CDC MMWR | 800+ | 每週 |
| US Travel Health Notices | 150+ | 不定期 |
| ECDC CDTR | 400+ | 每週 |
| UK UKHSA | 300+ | 不定期 |
| Taiwan CDC | 100+ | 不定期 |
| **總計** | **2,450+** | - |

### 技術規格

- **向量模型**: text-embedding-3-small (OpenAI)
- **向量維度**: 1536
- **資料庫**: Qdrant (向量搜尋引擎)
- **相似度計算**: 餘弦相似度 (Cosine Similarity)

---

## 使用限制

<div style="background: #f6f8fa; padding: 1rem; border-radius: 4px; margin: 1rem 0;">

| 方案 | 每日查詢次數 | 說明 |
|------|-------------|------|
| **免費版** | 10 次 / IP | 一般使用者 |
| **登入用戶** | 50 次 / 日 | 需註冊帳號（開發中） |
| **API 存取** | 依方案 | 需申請 API Key（開發中） |

</div>

---

## 開發者 API

<div style="background: #fff3cd; padding: 1rem; border-radius: 4px; margin: 1rem 0;">

**🚧 API 開放申請中**

如需大量查詢或整合至您的應用程式，請透過 [GitHub Issues](https://github.com/weiqi-kids/agent.disease-and-advisory/issues) 聯繫我們。

</div>

### API 使用範例（規劃中）

```bash
curl -X POST "https://api.epialert.weiqi.kids/v1/search" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "Marburg virus outbreak", "limit": 10}'
```

---

## 相關功能

- [全站搜尋](/search) - 使用關鍵字搜尋網站內容
- [疾病專頁](../disease) - 查看特定疾病的詳細資訊
- [週報](../Narrator/weekly_digest) - 瀏覽每週疫情摘要

---

<div class="ymyl-disclaimer">

**免責聲明**：本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。

</div>
