---
title: 全球疫情地圖
layout: default
parent: 疫情地圖
nav_order: 2
seo:
  meta:
    title: '全球疫情地圖 — WHO/CDC/ECDC 報告事件分布'
    description: '全球傳染病分布互動地圖，整合 WHO、US CDC、ECDC、UKHSA 報告資料，視覺化呈現國際疫情熱點。'
  ymyl:
    lastReviewed: '2026-02-20'
    reviewedBy: 'EpiAlert AI 編輯'
    medicalDisclaimer: '本網站內容僅供參考，不構成醫療建議或診斷。如有健康疑慮，請諮詢專業醫療人員。'
---

# 全球疫情地圖
{: .speakable-content }

<p class="key-answer" data-question="全球疫情地圖顯示哪些資訊">全球疫情地圖整合 WHO、US CDC、ECDC、UKHSA 等官方來源的疫情報告，視覺化呈現各國傳染病事件分布與風險等級。</p>

整合 7 大官方來源的全球疫情分布互動地圖。

---

## 近期全球疫情事件

<div id="source-filter" style="margin-bottom: 1rem;">
  <span style="margin-right: 0.5rem;">篩選來源：</span>
  <button data-source="all" class="btn btn-sm active">全部</button>
  <button data-source="who" class="btn btn-sm">WHO</button>
  <button data-source="ecdc" class="btn btn-sm">ECDC</button>
  <button data-source="ukhsa" class="btn btn-sm">UKHSA</button>
  <button data-source="cdc" class="btn btn-sm">US CDC</button>
</div>

<style>
#source-filter button.active { background-color: #7253ed; color: white; }
#global-map { height: 500px; border-radius: 8px; border: 1px solid #ddd; }
.leaflet-popup-content { min-width: 220px; }
.risk-high { color: #dc3545; font-weight: bold; }
.risk-medium { color: #ffc107; font-weight: bold; }
.risk-low { color: #28a745; font-weight: bold; }
.source-badge { display: inline-block; padding: 2px 6px; border-radius: 4px; font-size: 0.8em; color: white; }
.source-who { background: #009edb; }
.source-ecdc { background: #003399; }
.source-ukhsa { background: #00205B; }
.source-cdc { background: #0033a0; }
</style>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

<div id="global-map"></div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // Initialize map with world view
  var map = L.map('global-map').setView([20, 0], 2);

  // Add OpenStreetMap tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);

  // Custom icons for risk levels
  var redIcon = L.divIcon({
    className: 'custom-marker',
    html: '<div style="background:#dc3545;width:28px;height:28px;border-radius:50%;border:3px solid white;box-shadow:0 2px 6px rgba(0,0,0,0.4);"></div>',
    iconSize: [28, 28],
    iconAnchor: [14, 14]
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

  // Global epidemic events data (from 2026-W08 weekly digest)
  var events = [
    {
      lat: 51.5,
      lng: -0.1,
      country: '英國',
      disease: '寒冷死亡率報告',
      risk: 'medium',
      date: '2026-02-18',
      description: '2024-25 冬季 2,544 例死亡與寒流相關，65 歲以上高風險',
      source: 'ukhsa',
      sourceName: 'UKHSA'
    },
    {
      lat: 50.8,
      lng: 4.3,
      country: '歐洲',
      disease: '抗生素抗藥性',
      risk: 'medium',
      date: '2026-02-18',
      description: '沙門氏菌、彎曲桿菌環丙沙星抗藥性高企，碳青黴烯酶檢出上升',
      source: 'ecdc',
      sourceName: 'ECDC'
    },
    {
      lat: 22.5,
      lng: 88.3,
      country: '印度（西孟加拉邦）',
      disease: '尼帕病毒',
      risk: 'medium',
      date: '2026-01-13',
      description: 'HCID 風險清單更新，確認爆發',
      source: 'ukhsa',
      sourceName: 'UKHSA'
    },
    {
      lat: 51.5,
      lng: -0.1,
      country: '英國',
      disease: 'RSV 疫苗 PGD',
      risk: 'low',
      date: '2026-02-18',
      description: '發布呼吸道融合病毒疫苗患者群組指示範本',
      source: 'ukhsa',
      sourceName: 'UKHSA'
    },
    {
      lat: 0,
      lng: 20,
      country: '全球',
      disease: '猴痘 Mpox',
      risk: 'low',
      date: '2026-02-18',
      description: 'Clade Ib/IIb 持續監測',
      source: 'who',
      sourceName: 'WHO'
    },
    {
      lat: 47.5,
      lng: 14.5,
      country: '歐洲',
      disease: '麻疹',
      risk: 'medium',
      date: '2026-02-09',
      description: '社區傳播持續驅動麻疹疫情',
      source: 'ecdc',
      sourceName: 'ECDC'
    },
    {
      lat: 46.0,
      lng: 11.0,
      country: '義大利',
      disease: '冬季奧運健康防護',
      risk: 'low',
      date: '2026-02-05',
      description: '2026 冬季奧運與帕運健康防護指引',
      source: 'ecdc',
      sourceName: 'ECDC'
    }
  ];

  var markers = [];

  // Add markers to map
  events.forEach(function(event) {
    var icon = event.risk === 'high' ? redIcon : (event.risk === 'medium' ? yellowIcon : greenIcon);
    var riskClass = 'risk-' + event.risk;
    var riskText = event.risk === 'high' ? '🔴 高' : (event.risk === 'medium' ? '🟡 中' : '🟢 低');
    var sourceClass = 'source-' + event.source;

    var popup = '<div>' +
      '<h4 style="margin:0 0 8px 0;">' + event.disease + '</h4>' +
      '<p style="margin:0 0 4px 0;"><strong>地點：</strong>' + event.country + '</p>' +
      '<p style="margin:0 0 4px 0;"><strong>日期：</strong>' + event.date + '</p>' +
      '<p style="margin:0 0 4px 0;"><strong>風險：</strong><span class="' + riskClass + '">' + riskText + '</span></p>' +
      '<p style="margin:0 0 4px 0;">' + event.description + '</p>' +
      '<p style="margin:0;"><span class="source-badge ' + sourceClass + '">' + event.sourceName + '</span></p>' +
      '</div>';

    var marker = L.marker([event.lat, event.lng], {icon: icon})
      .bindPopup(popup)
      .addTo(map);

    marker.source = event.source;
    markers.push(marker);
  });

  // Source filter functionality
  var filterButtons = document.querySelectorAll('#source-filter button');
  filterButtons.forEach(function(btn) {
    btn.addEventListener('click', function() {
      filterButtons.forEach(function(b) { b.classList.remove('active'); });
      this.classList.add('active');

      var source = this.getAttribute('data-source');

      markers.forEach(function(marker) {
        if (source === 'all' || marker.source === source) {
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
| 🔴 紅色 | 高風險 | PHEIC / 大規模爆發 / 跨國傳播 |
| 🟡 黃色 | 中風險 | 區域爆發 / 新興威脅 / 持續監測 |
| 🟢 綠色 | 低風險 | 散發案例 / 常規監測 / 指引發布 |

---

## 各區域風險總覽

### 歐洲

| 國家/地區 | 事件 | 來源 | 風險 |
|-----------|------|------|------|
| 英國 | 寒冷死亡率報告 | UKHSA | 🟡 |
| 英國 | RSV 疫苗 PGD | UKHSA | 🟢 |
| 歐洲 | 抗生素抗藥性監測 | ECDC | 🟡 |
| 歐洲 | 麻疹社區傳播 | ECDC | 🟡 |
| 義大利 | 冬季奧運健康防護 | ECDC | 🟢 |

### 亞洲

| 國家/地區 | 事件 | 來源 | 風險 |
|-----------|------|------|------|
| 印度 | 尼帕病毒爆發 | UKHSA | 🟡 |
| 台灣 | 麻疹境外移入 | TW CDC | 🟢 |
| 台灣 | 百日咳首例 | TW CDC | 🟢 |

### 全球

| 事件 | 來源 | 風險 |
|------|------|------|
| 猴痘 Mpox 監測 | WHO | 🟢 |

---

## 資料來源

| 來源 | 涵蓋範圍 | 連結 |
|------|----------|------|
| WHO DON | 全球 | [疾病爆發新聞](../Extractor/who_disease_outbreak_news/) |
| ECDC CDTR | 歐洲 | [傳染病威脅報告](../Extractor/ecdc_cdtr/) |
| UKHSA | 英國 | [健康安全局更新](../Extractor/uk_ukhsa_updates/) |
| US CDC | 美國 | [HAN](../Extractor/us_cdc_han/) / [MMWR](../Extractor/us_cdc_mmwr/) |
| TW CDC | 台灣 | [疾管署警報](../Extractor/tw_cdc_alerts/) |

---

[← 返回地圖首頁](./){: .btn .btn-outline }
[查看台灣地圖](taiwan){: .btn }

---

<div class="ymyl-disclaimer">

**免責聲明**：地圖資料僅供參考，實際疫情狀況請以各國官方公告為準。地圖標示位置為國家/地區代表點，非實際發生地點。

</div>
