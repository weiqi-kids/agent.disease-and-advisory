# 系統維護指令

## 概覽

此目錄 (`core/`) 包含傳染病情報分析系統的核心定義檔案。當 Claude CLI 在此目錄下執行時，會載入本文件。

---

## 目錄結構

```
core/
├── CLAUDE.md              # 本文件 — 系統維護入口
├── Architect/
│   └── CLAUDE.md          # Architect 角色定義
├── Extractor/
│   ├── CLAUDE.md          # Extractor 通用規則
│   └── Layers/            # 各 Layer 定義
│       └── {layer_name}/
│           ├── CLAUDE.md  # Layer 定義
│           ├── fetch.sh   # 資料擷取腳本
│           └── update.sh  # Qdrant 更新腳本
└── Narrator/
    ├── CLAUDE.md          # Narrator 通用規則
    └── Modes/             # 各 Mode 定義
        └── {mode_name}/
            └── CLAUDE.md  # Mode 定義
```

---

## 維護操作

### Layer 管理

#### 新增 Layer

```
使用者：「新增一個 {名稱} Layer，資料來源是 {URL}」
```

執行步驟：
1. 確認 Layer 定義表（見根目錄 CLAUDE.md 第八節）
2. 確認 category enum 清單
3. 確認 WebFetch 策略
4. 確認 `[REVIEW_NEEDED]` 觸發規則
5. 建立 `core/Extractor/Layers/{layer_name}/` 目錄
6. 產生 `fetch.sh`、`update.sh`、`CLAUDE.md`
7. 建立 `docs/Extractor/{layer_name}/` 及 category 子目錄
8. 更新 `docs/explored.md`

#### 修改 Layer

1. 讀取現有 `CLAUDE.md` 確認現況
2. 與使用者確認修改內容
3. 修改對應檔案
4. 列出影響範圍

#### 暫停 / 啟用 Layer

- 暫停：`touch core/Extractor/Layers/{layer_name}/.disabled`
- 啟用：`rm core/Extractor/Layers/{layer_name}/.disabled`

### Mode 管理

操作方式與 Layer 管理類似，在 `core/Narrator/Modes/` 下操作。

---

## 注意事項

- 修改 Layer 的 category enum 時，需確認不影響既有資料
- 刪除 Layer/Mode 前，需列出依賴關係
- 所有變更需同步更新 `docs/explored.md`
