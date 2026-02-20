---
title: 台灣疫情地圖
layout: default
parent: 疫情地圖
nav_order: 1
seo:
  meta:
    title: '台灣疫情地圖 — 各縣市傳染病分布'
    description: '台灣 22 縣市傳染病分布互動地圖，整合台灣 CDC 通報資料，視覺化呈現境外移入與本土病例。'
  ymyl:
    lastReviewed: '2026-02-20'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# 台灣疫情地圖
{: .speakable-content }

<p class="key-answer" data-question="台灣疫情地圖顯示哪些資訊">台灣疫情地圖顯示各縣市的傳染病通報情況，包括麻疹、百日咳、登革熱等法定傳染病的境外移入與本土病例分布。</p>

台灣 22 縣市傳染病分布互動地圖。

---

## 近期疫情事件

<div id="disease-filter" style="margin-bottom: 1rem;">
  <span style="margin-right: 0.5rem;">篩選疾病：</span>
  <button data-disease="all" class="btn btn-sm active">全部</button>
  <button data-disease="measles" class="btn btn-sm">麻疹</button>
  <button data-disease="pertussis" class="btn btn-sm">百日咳</button>
  <button data-disease="dengue" class="btn btn-sm">登革熱</button>
</div>

<style>
#disease-filter button.active { background-color: #7253ed; color: white; }
#taiwan-map { height: 500px; border-radius: 8px; border: 1px solid #ddd; }
.leaflet-popup-content { min-width: 200px; }
.risk-high { color: #dc3545; font-weight: bold; }
.risk-medium { color: #ffc107; font-weight: bold; }
.risk-low { color: #28a745; font-weight: bold; }
</style>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

<div id="taiwan-map"></div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // Initialize map centered on Taiwan
  var map = L.map('taiwan-map').setView([23.5, 121], 7);

  // Add OpenStreetMap tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);

  // Custom icons for risk levels
  var redIcon = L.divIcon({
    className: 'custom-marker',
    html: '<div style="background:#dc3545;width:24px;height:24px;border-radius:50%;border:2px solid white;box-shadow:0 2px 4px rgba(0,0,0,0.3);"></div>',
    iconSize: [24, 24],
    iconAnchor: [12, 12]
  });

  var yellowIcon = L.divIcon({
    className: 'custom-marker',
    html: '<div style="background:#ffc107;width:24px;height:24px;border-radius:50%;border:2px solid white;box-shadow:0 2px 4px rgba(0,0,0,0.3);"></div>',
    iconSize: [24, 24],
    iconAnchor: [12, 12]
  });

  var greenIcon = L.divIcon({
    className: 'custom-marker',
    html: '<div style="background:#28a745;width:20px;height:20px;border-radius:50%;border:2px solid white;box-shadow:0 2px 4px rgba(0,0,0,0.3);"></div>',
    iconSize: [20, 20],
    iconAnchor: [10, 10]
  });

  // Epidemic events data (from 2026-W08 weekly digest)
  var events = [
    {
      lat: 25.033,
      lng: 121.565,
      city: '台北市',
      disease: 'measles',
      diseaseName: '麻疹',
      risk: 'low',
      date: '2026-02-16',
      description: '今年首例境外移入麻疹，越南感染，400 名接觸者監測至 2/28',
      source: 'TW CDC'
    },
    {
      lat: 24.147,
      lng: 120.673,
      city: '台中市',
      disease: 'pertussis',
      diseaseName: '百日咳',
      risk: 'low',
      date: '2026-02-16',
      description: '今年首例百日咳確診，家庭接觸者監測至 3/4',
      source: 'TW CDC'
    },
    {
      lat: 22.627,
      lng: 120.301,
      city: '高雄市',
      disease: 'dengue',
      diseaseName: '登革熱',
      risk: 'low',
      date: '2026-02-10',
      description: '散發境外移入登革熱，東南亞旅遊返國',
      source: 'TW CDC'
    },
    {
      lat: 25.012,
      lng: 121.463,
      city: '新北市',
      disease: 'measles',
      diseaseName: '麻疹',
      risk: 'low',
      date: '2026-02-16',
      description: '麻疹接觸者監測範圍（首例相關）',
      source: 'TW CDC'
    }
  ];

  var markers = [];

  // Add markers to map
  events.forEach(function(event) {
    var icon = event.risk === 'high' ? redIcon : (event.risk === 'medium' ? yellowIcon : greenIcon);
    var riskClass = 'risk-' + event.risk;
    var riskText = event.risk === 'high' ? '🔴 高' : (event.risk === 'medium' ? '🟡 中' : '🟢 低');

    var popup = '<div>' +
      '<h4 style="margin:0 0 8px 0;">' + event.diseaseName + '</h4>' +
      '<p style="margin:0 0 4px 0;"><strong>地點：</strong>' + event.city + '</p>' +
      '<p style="margin:0 0 4px 0;"><strong>日期：</strong>' + event.date + '</p>' +
      '<p style="margin:0 0 4px 0;"><strong>風險：</strong><span class="' + riskClass + '">' + riskText + '</span></p>' +
      '<p style="margin:0 0 4px 0;">' + event.description + '</p>' +
      '<p style="margin:0;font-size:0.9em;color:#666;">來源：' + event.source + '</p>' +
      '</div>';

    var marker = L.marker([event.lat, event.lng], {icon: icon})
      .bindPopup(popup)
      .addTo(map);

    marker.disease = event.disease;
    markers.push(marker);
  });

  // Disease filter functionality
  var filterButtons = document.querySelectorAll('#disease-filter button');
  filterButtons.forEach(function(btn) {
    btn.addEventListener('click', function() {
      filterButtons.forEach(function(b) { b.classList.remove('active'); });
      this.classList.add('active');

      var disease = this.getAttribute('data-disease');

      markers.forEach(function(marker) {
        if (disease === 'all' || marker.disease === disease) {
          marker.addTo(map);
        } else {
          map.removeLayer(marker);
        }
      });
    });
  });
});
</script>

---

## 圖例說明

| 標示 | 風險等級 | 說明 |
|------|----------|------|
| 🔴 紅色 | 高風險 | 本土群聚或大規模爆發 |
| 🟡 黃色 | 中風險 | 本土散發或持續監測 |
| 🟢 綠色 | 低風險 | 境外移入或個案監測 |

---

## 2026 年台灣疫情統計

| 疾病 | 境外移入 | 本土病例 | 狀態 |
|------|----------|----------|------|
| 麻疹 | 1 | 0 | 🟢 監測中 |
| 百日咳 | 0 | 1 | 🟢 監測中 |
| 登革熱 | 3 | 0 | 🟢 正常 |
| COVID-19 | - | 持續 | 🟢 地方性流行 |
| 流感 | - | 持續 | 🟡 季節性流行 |

---

## 縣市分布

### 北部地區

| 縣市 | 近期事件 | 風險等級 |
|------|----------|----------|
| 台北市 | 麻疹境外移入、接觸者監測 | 🟢 |
| 新北市 | 麻疹接觸者監測範圍 | 🟢 |
| 基隆市 | 無特殊 | 🟢 |
| 桃園市 | 無特殊 | 🟢 |
| 新竹縣市 | 無特殊 | 🟢 |

### 中部地區

| 縣市 | 近期事件 | 風險等級 |
|------|----------|----------|
| 台中市 | 百日咳首例 | 🟢 |
| 彰化縣 | 無特殊 | 🟢 |
| 南投縣 | 無特殊 | 🟢 |
| 雲林縣 | 無特殊 | 🟢 |

### 南部地區

| 縣市 | 近期事件 | 風險等級 |
|------|----------|----------|
| 台南市 | 無特殊 | 🟢 |
| 高雄市 | 登革熱境外移入 | 🟢 |
| 屏東縣 | 無特殊 | 🟢 |

### 東部與離島

| 縣市 | 近期事件 | 風險等級 |
|------|----------|----------|
| 宜蘭縣 | 無特殊 | 🟢 |
| 花蓮縣 | 無特殊 | 🟢 |
| 台東縣 | 無特殊 | 🟢 |
| 澎湖縣 | 無特殊 | 🟢 |
| 金門縣 | 無特殊 | 🟢 |
| 連江縣 | 無特殊 | 🟢 |

---

## 資料來源

- [台灣 CDC 傳染病統計資料](https://nidss.cdc.gov.tw/)
- [EpiAlert 週報](../Narrator/weekly_digest/)

---

[← 返回地圖首頁](./){: .btn .btn-outline }
[查看全球地圖 →](global){: .btn }

---

<div class="ymyl-disclaimer">

**免責聲明**：地圖資料僅供參考，實際疫情狀況請以台灣 CDC 官方公告為準。地圖標示位置為縣市代表點，非實際發生地點。

</div>
