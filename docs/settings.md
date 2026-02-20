---
title: 個人設定
layout: default
nav_order: 9
seo:
  meta:
    title: '個人設定 — 自訂 EpiAlert 顯示偏好'
    description: '自訂 EpiAlert 顯示偏好：關注地區、追蹤疾病、語言設定。所有設定儲存於本機，不上傳伺服器。'
  ymyl:
    lastReviewed: '2026-02-20'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# 個人設定
{: .speakable-content }

<p class="key-answer" data-question="EpiAlert 個人化功能有哪些">EpiAlert 提供地區偏好、疾病追蹤、語言設定等個人化功能。所有設定儲存於瀏覽器本機，不上傳伺服器，保護您的隱私。</p>

自訂您的 EpiAlert 顯示偏好。所有設定僅儲存於本機瀏覽器。

---

## 關注地區

選擇您關注的地區，首頁會優先顯示相關疫情：

<div id="region-settings" style="margin: 1rem 0;">
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="region" value="taiwan" class="region-checkbox"> 🇹🇼 台灣
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="region" value="asia" class="region-checkbox"> 🌏 亞洲（日本、韓國、東南亞等）
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="region" value="europe" class="region-checkbox"> 🇪🇺 歐洲
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="region" value="americas" class="region-checkbox"> 🌎 美洲
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="region" value="africa" class="region-checkbox"> 🌍 非洲
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="region" value="global" class="region-checkbox"> 🌐 全球（WHO 公告）
  </label>
</div>

---

## 追蹤疾病

選擇您想追蹤的疾病類型：

<div id="disease-settings" style="margin: 1rem 0;">
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="disease" value="respiratory" class="disease-checkbox"> 🫁 呼吸道疾病（流感、COVID-19、RSV）
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="disease" value="vaccine-preventable" class="disease-checkbox"> 💉 疫苗可預防（麻疹、百日咳、水痘）
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="disease" value="vector-borne" class="disease-checkbox"> 🦟 病媒傳播（登革熱、日本腦炎）
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="disease" value="gastrointestinal" class="disease-checkbox"> 🍽️ 腸胃道（諾羅病毒、腸病毒）
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="disease" value="emerging" class="disease-checkbox"> ⚠️ 新興傳染病（猴痘、尼帕病毒）
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="disease" value="amr" class="disease-checkbox"> 💊 抗藥性（AMR 監測）
  </label>
</div>

---

## 風險等級篩選

選擇要顯示的風險等級：

<div id="risk-settings" style="margin: 1rem 0;">
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="risk" value="high" class="risk-checkbox" checked> 🔴 高風險
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="risk" value="medium" class="risk-checkbox" checked> 🟡 中風險
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" name="risk" value="low" class="risk-checkbox" checked> 🟢 低風險
  </label>
</div>

---

## 語言偏好

<div id="language-settings" style="margin: 1rem 0;">
  <label style="display: block; margin: 0.5rem 0;">
    <input type="radio" name="language" value="zh-TW" checked> 繁體中文
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="radio" name="language" value="en"> English
  </label>
</div>

---

## 顯示選項

<div id="display-settings" style="margin: 1rem 0;">
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" id="show-charts" checked> 📊 顯示圖表
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" id="show-maps" checked> 🗺️ 顯示地圖
  </label>
  <label style="display: block; margin: 0.5rem 0;">
    <input type="checkbox" id="compact-view"> 📱 精簡模式
  </label>
</div>

---

<div style="margin: 2rem 0;">
  <button id="save-settings" class="btn btn-primary">💾 儲存設定</button>
  <button id="reset-settings" class="btn btn-outline" style="margin-left: 0.5rem;">🔄 重設為預設</button>
</div>

<div id="save-status" style="display: none; margin-top: 1rem; padding: 1rem; border-radius: 4px;"></div>

---

## 我的收藏

<div id="bookmarks-section">
  <p>您尚未收藏任何文章。瀏覽週報時點擊 ⭐ 即可加入收藏。</p>
  <ul id="bookmarks-list" style="list-style: none; padding: 0;"></ul>
</div>

---

## 瀏覽紀錄

<div id="history-section">
  <p>您的近期瀏覽紀錄：</p>
  <ul id="history-list" style="list-style: none; padding: 0;"></ul>
  <button id="clear-history" class="btn btn-sm btn-outline">清除紀錄</button>
</div>

---

<style>
.settings-saved {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}
.settings-reset {
  background: #fff3cd;
  color: #856404;
  border: 1px solid #ffeeba;
}
.bookmark-item, .history-item {
  padding: 0.5rem;
  margin: 0.25rem 0;
  background: #f6f8fa;
  border-radius: 4px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.remove-btn {
  background: none;
  border: none;
  color: #dc3545;
  cursor: pointer;
  font-size: 1.2em;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
  var STORAGE_KEY = 'epialert_settings';

  // Default settings
  var defaultSettings = {
    regions: ['taiwan'],
    diseases: ['respiratory', 'vaccine-preventable'],
    risks: ['high', 'medium', 'low'],
    language: 'zh-TW',
    showCharts: true,
    showMaps: true,
    compactView: false,
    bookmarks: [],
    history: []
  };

  // Load settings
  function loadSettings() {
    try {
      var saved = localStorage.getItem(STORAGE_KEY);
      return saved ? JSON.parse(saved) : defaultSettings;
    } catch (e) {
      return defaultSettings;
    }
  }

  // Save settings
  function saveSettings(settings) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(settings));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Apply settings to form
  function applyToForm(settings) {
    // Regions
    document.querySelectorAll('.region-checkbox').forEach(function(cb) {
      cb.checked = settings.regions.includes(cb.value);
    });

    // Diseases
    document.querySelectorAll('.disease-checkbox').forEach(function(cb) {
      cb.checked = settings.diseases.includes(cb.value);
    });

    // Risks
    document.querySelectorAll('.risk-checkbox').forEach(function(cb) {
      cb.checked = settings.risks.includes(cb.value);
    });

    // Language
    document.querySelectorAll('input[name="language"]').forEach(function(rb) {
      rb.checked = rb.value === settings.language;
    });

    // Display options
    document.getElementById('show-charts').checked = settings.showCharts;
    document.getElementById('show-maps').checked = settings.showMaps;
    document.getElementById('compact-view').checked = settings.compactView;

    // Bookmarks
    renderBookmarks(settings.bookmarks);

    // History
    renderHistory(settings.history);
  }

  // Get settings from form
  function getFromForm() {
    var settings = loadSettings();

    settings.regions = [];
    document.querySelectorAll('.region-checkbox:checked').forEach(function(cb) {
      settings.regions.push(cb.value);
    });

    settings.diseases = [];
    document.querySelectorAll('.disease-checkbox:checked').forEach(function(cb) {
      settings.diseases.push(cb.value);
    });

    settings.risks = [];
    document.querySelectorAll('.risk-checkbox:checked').forEach(function(cb) {
      settings.risks.push(cb.value);
    });

    var langRadio = document.querySelector('input[name="language"]:checked');
    settings.language = langRadio ? langRadio.value : 'zh-TW';

    settings.showCharts = document.getElementById('show-charts').checked;
    settings.showMaps = document.getElementById('show-maps').checked;
    settings.compactView = document.getElementById('compact-view').checked;

    return settings;
  }

  // Render bookmarks
  function renderBookmarks(bookmarks) {
    var list = document.getElementById('bookmarks-list');
    var section = document.getElementById('bookmarks-section');

    if (!bookmarks || bookmarks.length === 0) {
      list.innerHTML = '';
      section.querySelector('p').style.display = 'block';
      return;
    }

    section.querySelector('p').style.display = 'none';
    list.innerHTML = bookmarks.map(function(bm, i) {
      return '<li class="bookmark-item">' +
        '<a href="' + bm.url + '">' + bm.title + '</a>' +
        '<button class="remove-btn" data-index="' + i + '" data-type="bookmark">×</button>' +
        '</li>';
    }).join('');
  }

  // Render history
  function renderHistory(history) {
    var list = document.getElementById('history-list');

    if (!history || history.length === 0) {
      list.innerHTML = '<li style="color: #666;">暫無瀏覽紀錄</li>';
      return;
    }

    list.innerHTML = history.slice(0, 10).map(function(item) {
      return '<li class="history-item">' +
        '<a href="' + item.url + '">' + item.title + '</a>' +
        '<span style="color:#666;font-size:0.9em;">' + item.date + '</span>' +
        '</li>';
    }).join('');
  }

  // Show status message
  function showStatus(message, type) {
    var status = document.getElementById('save-status');
    status.textContent = message;
    status.className = type === 'success' ? 'settings-saved' : 'settings-reset';
    status.style.display = 'block';
    setTimeout(function() {
      status.style.display = 'none';
    }, 3000);
  }

  // Initialize
  var currentSettings = loadSettings();
  applyToForm(currentSettings);

  // Save button
  document.getElementById('save-settings').addEventListener('click', function() {
    var settings = getFromForm();
    if (saveSettings(settings)) {
      showStatus('✅ 設定已儲存！', 'success');
    }
  });

  // Reset button
  document.getElementById('reset-settings').addEventListener('click', function() {
    if (confirm('確定要重設為預設設定嗎？')) {
      saveSettings(defaultSettings);
      applyToForm(defaultSettings);
      showStatus('🔄 已重設為預設設定', 'reset');
    }
  });

  // Clear history
  document.getElementById('clear-history').addEventListener('click', function() {
    var settings = loadSettings();
    settings.history = [];
    saveSettings(settings);
    renderHistory([]);
  });

  // Remove bookmark/history item
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('remove-btn')) {
      var index = parseInt(e.target.dataset.index);
      var type = e.target.dataset.type;
      var settings = loadSettings();

      if (type === 'bookmark') {
        settings.bookmarks.splice(index, 1);
        saveSettings(settings);
        renderBookmarks(settings.bookmarks);
      }
    }
  });
});
</script>

---

## 隱私說明

| 項目 | 說明 |
|------|------|
| 儲存位置 | 瀏覽器本機 (localStorage) |
| 上傳伺服器 | ❌ 否 |
| 跨裝置同步 | ❌ 否（每個裝置獨立） |
| 清除方式 | 清除瀏覽器資料或點擊「重設為預設」 |

---

## 常見問題

### 換裝置後設定會消失嗎？

是的。設定儲存於瀏覽器本機，不會同步到其他裝置。

### 清除瀏覽器資料會影響設定嗎？

會。清除 cookies 和網站資料時，設定會一併清除。

### 這些設定會影響什麼？

目前主要影響首頁的地區篩選預設值。未來將擴展更多個人化功能。

---

<div class="ymyl-disclaimer">

**隱私聲明**：所有個人設定僅儲存於您的瀏覽器本機，EpiAlert 不會收集或上傳您的偏好設定。

</div>
