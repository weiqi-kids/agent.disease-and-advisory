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

可透過以下方式取得資料：
1. 直接讀取 `docs/Extractor/` 下的 .md 檔案
2. 從 Qdrant 向量資料庫查詢（需要語意搜尋時）

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

- [ ] 已包含免責聲明
- [ ] 已列出所有資料來源
- [ ] 引用的資料確實存在於 `docs/Extractor/`
- [ ] 未產出無法驗證的「專業外觀」聲明
- [ ] 推測與事實已明確區分
- [ ] 未混淆不同 Layer 的資訊

---

## Phase 2 規劃

以下 Mode 將在 Phase 2 實作：

- **weekly_digest** — 週報摘要
- **outbreak_tracker** — 疫情追蹤
- **travel_advisory** — 旅遊建議

各 Mode 的詳細定義將在 Phase 2 建立。
