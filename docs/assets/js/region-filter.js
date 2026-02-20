/**
 * Region filter for weekly highlights table
 * Filters table rows based on selected region
 */
(function() {
  'use strict';

  // Region mapping - maps regions to keywords that might appear in the location column
  var regionKeywords = {
    'all': null,
    'asia': ['台灣', '日本', '中國', '韓國', '印度', '泰國', '越南', '馬來西亞', '印尼', '菲律賓', '新加坡', '香港', '澳門', '亞洲', 'Taiwan', 'Japan', 'China', 'Korea', 'India', 'Thailand', 'Vietnam', 'Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Asia'],
    'europe': ['英國', '法國', '德國', '義大利', '西班牙', '荷蘭', '比利時', '瑞士', '瑞典', '挪威', '丹麥', '芬蘭', '波蘭', '歐洲', 'UK', 'France', 'Germany', 'Italy', 'Spain', 'Netherlands', 'Belgium', 'Switzerland', 'Sweden', 'Norway', 'Denmark', 'Finland', 'Poland', 'Europe', 'ECDC'],
    'americas': ['美國', '加拿大', '墨西哥', '巴西', '阿根廷', '智利', '哥倫比亞', '秘魯', '美洲', 'US', 'USA', 'Canada', 'Mexico', 'Brazil', 'Argentina', 'Chile', 'Colombia', 'Peru', 'Americas'],
    'africa': ['非洲', '南非', '埃及', '奈及利亞', '肯亞', '剛果', '盧安達', 'Africa', 'South Africa', 'Egypt', 'Nigeria', 'Kenya', 'Congo', 'Rwanda'],
    'oceania': ['澳洲', '紐西蘭', '大洋洲', 'Australia', 'New Zealand', 'Oceania'],
    'global': ['全球', '多國', '國際', 'Global', 'International', 'Worldwide', 'Multiple']
  };

  function initRegionFilter() {
    var filterContainer = document.getElementById('region-filter');
    var table = document.getElementById('weekly-highlights');

    if (!filterContainer || !table) {
      return;
    }

    var buttons = filterContainer.querySelectorAll('button[data-region]');
    var rows = table.querySelectorAll('tbody tr');

    buttons.forEach(function(button) {
      button.addEventListener('click', function() {
        var region = this.getAttribute('data-region');

        // Update active button
        buttons.forEach(function(btn) {
          btn.classList.remove('active');
        });
        this.classList.add('active');

        // Filter rows
        filterRows(rows, region);
      });
    });
  }

  function filterRows(rows, region) {
    var keywords = regionKeywords[region];
    var visibleCount = 0;

    rows.forEach(function(row) {
      var locationCell = row.cells[2]; // Third column is location
      if (!locationCell) return;

      var locationText = locationCell.textContent;
      var shouldShow = false;

      if (region === 'all' || !keywords) {
        shouldShow = true;
      } else {
        for (var i = 0; i < keywords.length; i++) {
          if (locationText.indexOf(keywords[i]) !== -1) {
            shouldShow = true;
            break;
          }
        }
      }

      row.style.display = shouldShow ? '' : 'none';
      if (shouldShow) visibleCount++;
    });

    // Show message if no results
    updateNoResultsMessage(visibleCount, region);
  }

  function updateNoResultsMessage(count, region) {
    var table = document.getElementById('weekly-highlights');
    var existingMsg = document.getElementById('no-results-msg');

    if (count === 0) {
      if (!existingMsg) {
        var msg = document.createElement('p');
        msg.id = 'no-results-msg';
        msg.style.textAlign = 'center';
        msg.style.padding = '1rem';
        msg.style.color = '#666';
        msg.textContent = '此區域本週無重點疫情事件';
        table.parentNode.insertBefore(msg, table.nextSibling);
      }
    } else if (existingMsg) {
      existingMsg.remove();
    }
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initRegionFilter);
  } else {
    initRegionFilter();
  }
})();
