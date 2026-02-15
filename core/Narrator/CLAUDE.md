# Narrator 通用規則

## 角色概覽

| 項目 | 說明 |
|------|------|
| **角色名稱** | Narrator |
| **職責** | 跨來源綜合分析、報告產出 |
| **實現方式** | `core/Narrator/Modes/` 下的 Mode 定義 |

---

## 資料來源

Narrator 讀取 Extractor 產出的結構化資料：

```
docs/Extractor/{layer_name}/{category}/*.md
```

### 取得資料的兩種方式

| 方式 | 用途 | 工具 |
|------|------|------|
| **檔案系統** | 讀取本週最新資料 | `find`, `glob`, 直接讀取 .md |
| **語意搜尋** | 查詢歷史相關資料 | `lib/report.sh` 函式 |

### 語意搜尋（Qdrant）

> **重要**：產出報告時**必須使用語意搜尋**查詢歷史資料，提供更完整的脈絡。

```bash
source lib/report.sh

# 搜尋相關歷史資料
report_semantic_search "Marburg virus outbreak" 10

# 尋找相似疾病記錄
report_find_similar "登革熱" 5

# 跨來源交叉驗證
report_cross_reference "H5N1" "ecdc_cdtr"

# 取得歷史脈絡
report_historical_context "Mpox"
```

語意搜尋可回答：
- 「過去有沒有類似疫情？結果如何？」
- 「其他來源有沒有報導這個疾病？」
- 「這個地區歷史上的疫情模式？」

---

## Mode 執行規則

### 模型指派

> **重要**：Mode 報告產出**必須使用 opus 模型**。
> 這是因為報告需要跨來源綜合分析、趨勢判斷，需要更強的推理能力。

### 執行順序

Mode 依序執行，不可平行：
- 後一 Mode 可能依賴前一 Mode 的輸出作為上下文
- 各 Mode 的 CLAUDE.md 應宣告依賴關係（若有）

---

## 報告產出通用規範

### 輸出位置

```
docs/Narrator/{mode_name}/{YYYY}-W{WW}-{report_name}.md
docs/Narrator/{mode_name}/{YYYY}-W{WW}-{report_name}.html  （自動產生）
```

### Frontmatter 必填欄位

> **重要**：所有報告檔案的 frontmatter 必須包含以下欄位以避免出現在側邊欄導航。

```yaml
---
nav_exclude: true
title: '{報告標題}'
layout: default
parent: 週報
description: '{SEO 描述，155 字內}'
---
```

| 欄位 | 必填 | 說明 |
|------|------|------|
| `nav_exclude` | ✅ | 必須為 `true` |
| `title` | ✅ | 報告標題（≤60 字元） |
| `layout` | ✅ | 必須為 `default` |
| `parent` | ✅ | 父級導航（如「週報」） |
| `description` | ❌ | SEO 描述（≤155 字元） |

> **注意**：若標題包含雙引號 `"`，外層必須使用單引號 `'` 包覆。

### SEO 相關欄位

> 這些欄位支援 `_includes/head_custom.html` 自動生成 JSON-LD Schema。

| 欄位 | 用途 |
|------|------|
| `title` | 用於 Article.headline、og:title |
| `description` | 用於 meta description、og:description |
| `parent` | 用於 BreadcrumbList 導航 |

報告中的 SEO 優化元素：
- `.key-takeaway`：適用於「本週重點」區塊
- `.actionable-steps`：適用於「防護建議」區塊

### 命名規範

- `YYYY`：年份
- `WW`：週數（兩位數）
- `report_name`：報告名稱（依 Mode 定義）

### HTML 自動轉換

報告產出後，必須自動轉換為 HTML 格式以方便客戶閱讀：

```bash
source lib/html.sh
html_convert_md docs/Narrator/{mode_name}/{report_file}.md
```

轉換流程：
1. 報告 .md 檔案寫入完成後
2. 執行 `html_convert_md` 轉換為 .html
3. HTML 檔案輸出至同目錄，檔名相同但副檔名為 .html

> **注意**：此步驟由頂層編排執行，不由 Mode 子代理自行處理。

### 必備內容

每份報告必須包含：

1. **免責聲明** — 報告的使用限制與法律聲明
2. **資料來源** — 列出引用的 Layer 和資料範圍
3. **產出時間** — 報告生成時間戳

---

## 免責聲明範本

每份報告開頭必須包含以下免責聲明：

```markdown
> **免責聲明**
>
> 本報告由自動化系統生成，僅供參考用途。報告內容基於公開資訊來源，
> 不構成醫療建議、官方政策或專業診斷。使用者應自行驗證資訊並諮詢
> 專業人士。報告產出者不對因使用本報告而產生的任何損失負責。
```

---

## 引用格式

引用 Extractor 資料時，使用以下格式：

```markdown
根據 [CDC Health Alert Network 2024-01-15](/docs/Extractor/us_cdc_han/advisory/2024-01-15-example.md)...
```

---

## 自我審核通用 Checklist

報告發布前，必須確認：

**基本欄位**：
- [ ] `nav_exclude: true` 存在於 frontmatter 開頭
- [ ] `title` 若包含 `"` 則使用單引號包覆
- [ ] 已包含免責聲明
- [ ] 已列出所有資料來源
- [ ] 引用的資料確實存在於 `docs/Extractor/`
- [ ] 未產出無法驗證的「專業外觀」聲明
- [ ] 推測與事實已明確區分
- [ ] 未混淆不同 Layer 的資訊

**SEO 優化**：
- [ ] `title` 長度 ≤ 60 字元
- [ ] `description` 若提供，長度 ≤ 155 字元
- [ ] `parent` 正確設定（用於 BreadcrumbList 導航）
- [ ] 「本週重點」區塊可標記為 `.key-takeaway`
- [ ] 「防護建議」區塊可標記為 `.actionable-steps`

---

## Phase 2 規劃

以下 Mode 將在 Phase 2 實作：

- **weekly_digest** — 週報摘要
- **outbreak_tracker** — 疫情追蹤
- **travel_advisory** — 旅遊建議

各 Mode 的詳細定義將在 Phase 2 建立。
