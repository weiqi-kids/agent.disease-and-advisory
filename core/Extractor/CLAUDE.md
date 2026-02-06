# Extractor 通用規則

## 角色概覽

| 項目 | 說明 |
|------|------|
| **角色名稱** | Extractor |
| **職責** | 資料擷取（fetch）與萃取（extract） |
| **實現方式** | `core/Extractor/Layers/` 下的 Layer 定義 + shell 腳本 |

---

## 資料流

```
外部資料源（RSS/API）
  → fetch.sh 下載原始資料 → docs/Extractor/{layer}/raw/*.jsonl
  → Claude 萃取（逐行處理）→ docs/Extractor/{layer}/{category}/*.md
  → update.sh 寫入 Qdrant + 檢查 REVIEW_NEEDED
```

---

## JSONL 處理規範

### 禁止行為

> **⛔ 禁止使用 Read 工具直接讀取 `.jsonl` 檔案**
> JSONL 檔案可能數百 KB，直接讀取會超出 token 上限。

### 正確流程

```bash
# 1. 取得總行數
wc -l < {jsonl_file}

# 2. 逐行讀取
sed -n '{N}p' {jsonl_file}

# 3. 每行交由一個 Task 子代理處理
# 4. 子代理透過 Write tool 寫出 .md 檔
```

---

## 萃取前去重

在分派萃取 Task 前，頂層編排邏輯需檢查：

1. 讀取 JSONL 中該筆的 `link` 或 `source_url`
2. 檢查 `docs/Extractor/{layer_name}/` 下是否已存在相同 URL 的 `.md` 檔
3. 若存在且內容相同 → 跳過
4. 若存在但內容不同 → 依 Layer 策略處理

去重檢查由頂層執行，不由子代理自行判斷。

---

## WebFetch 補充機制

### 通用規則

- RSS 的 `description` 欄位資訊量有限
- 各 Layer 的 CLAUDE.md 定義 WebFetch 使用策略
- WebFetch 失敗**不阻斷**萃取流程
- 降級時需在 `notes` 欄位標註

### 策略類型

| 策略 | 說明 | 適用場景 |
|------|------|----------|
| **必用** | 一律使用 WebFetch | RSS description 幾乎無資訊 |
| **按需** | description 不足時使用 | description 有時完整有時不足 |
| **不使用** | 完全基於 RSS 資料 | RSS 本身已包含完整結構化資料 |

---

## `[REVIEW_NEEDED]` 標記規範

### 統一原則

| 概念 | 含義 |
|------|------|
| `[REVIEW_NEEDED]` | 萃取結果**可能有誤**，需要人工確認 |
| `confidence: 低` | 資料來源有**結構性限制** |

> **兩者不等價。** 子任務不可自行擴大判定範圍。

### 子任務合規

- 必須**嚴格遵循** Layer CLAUDE.md 定義的觸發規則
- 不可因「僅單一來源、無交叉驗證」而自行標記
- 不可因「欄位為空」（資料來源本身不提供該欄位）而標記

---

## 萃取輸出通用欄位

每個 Layer 可定義額外欄位，但以下為通用欄位：

| 欄位 | 必填 | 說明 |
|------|------|------|
| `title` | ✅ | 標題 |
| `source_url` | ✅ | 原始連結（用於去重） |
| `date` | ✅ | 發布日期（ISO 8601） |
| `source_layer` | ✅ | Layer 名稱 |
| `category` | ✅ | 分類（依 Layer enum） |
| `summary` | ✅ | 摘要 |
| `confidence` | ✅ | 信心度（高/中/低） |
| `notes` | ❌ | 補充說明（如 WebFetch 降級） |

---

## 輸出檔案命名規範

```
docs/Extractor/{layer_name}/{category}/{YYYY-MM-DD}-{slug}.md
```

- `slug`：從標題生成的 URL 友好字串
- 避免特殊字元、空格轉為連字號
- 長度限制 50 字元

---

## 自我審核通用 Checklist

萃取輸出前，子代理必須確認：

- [ ] `source_url` 與原始資料一致
- [ ] `date` 格式正確（ISO 8601）
- [ ] `category` 屬於該 Layer 的 enum 定義
- [ ] `summary` 基於原始資料，無憑空推測
- [ ] 若有 WebFetch 降級，已在 `notes` 標註
- [ ] 若符合 REVIEW_NEEDED 觸發規則，已在開頭標記
