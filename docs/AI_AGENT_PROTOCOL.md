# AI Agent Collaboration Protocol (AACS)

本文件定義了跨專案的 **AI 代理人協作標準 (AI Agent Collaboration Standard)**。
當您 (AI Agent) 進入一個新的專案環境時，請遵循以下協定以確保高效、一致且可維護的開發流程。

## 1. 🔍 探索階段 (Discovery Phase)
- **優先尋找指南 (Seek Guidelines First)**：
    - 進入任何專案，優先檢查根目錄是否存在 `GEMINI.md`、`AI_GUIDELINES.md` 或 `.agent/GUIDELINES.md`。
    - 若存在，**必須**先閱讀該檔案以理解專案特定的路徑規範、效能要求與自愈邏輯。
- **架構可視化 (Visualize Architecture)**：
    - 檢查專案是否已定義了資料流向圖 (Mermaid)。若無，且專案結構複雜，應主動提議建立。

## 2. 💻 開發階段 (Development Phase)
- **脈絡持久化 (Persist Context)**：
    - 重大架構變更 (Refactor) 或效能優化 (Perf) 後，**必須**更新 `CHANGELOG.md` 的 `Unreleased` 區塊，並註明「為什麼這樣改 (Why)」，防止未來的 Agent 誤刪優化邏輯。
- **自我解釋性代碼 (Self-Explanatory Code)**：
    - 所有腳本必須包含標準的 **標頭註解 (Header)** 與 **啟動提示 (Startup Message)**，明確告知執行者該腳本的功能與副作用。
    - **標頭範例**:
      ```powershell
      # ==============================================================================
      # 腳本名稱: script_name.ps1
      # 功能描述: 簡述腳本核心功能。
      # ==============================================================================
      ```
    - **啟動提示範例**:
      ```powershell
      Write-Host ">>> 腳本名稱" -ForegroundColor Yellow
      Write-Host "功能：描述腳本執行動作..." -ForegroundColor Gray
      Write-Host ""
      ```

## 3. 🚀 效能意識 (Performance Awareness)
- **平行處理 (Parallel Processing)**：
    - 對於涉及網路等待 (Network IO) 或大量檔案操作的批次任務，預設採用 PowerShell 7 的 `ForEach-Object -Parallel` 進行優化。
    - **併發限制 (Concurrency Limit)**：為避免觸發外部 API (如 GitHub) Rate Limit，預設 ThrottleLimit **不得超過 5**。
- **記憶體緩衝 (Memory Buffer)**：
    - 在平行處理中，**嚴禁**使用多執行緒直接寫入同一檔案（避免 File Lock）。
    - **必須**使用管線 (Pipeline) 將日誌訊息回傳至主執行緒變數 (`$buffer`)，待處理完畢後再一次性批次寫入 (Batch Write)。
- **資源鎖定 (Resource Locking)**：
    - 若情境無法使用 Buffer，必須使用 `[System.Threading.Monitor]` 進行互斥鎖處理。

## 4. 🛡️ 自愈與容錯 (Self-Healing & Resilience)
- **環境感知**：
    - 啟動時自動檢查並載入 `.env` 設定。
    - 若涉及權限操作（如 GitHub API），自動執行 `gh auth switch` 確保身份正確。
- **智慧過濾 (Smart Filtering)**：
    - 除非有明確指令，否則預設跳過 **Private (私有)**、**Fork (分支)** 以及標記為 **✅ (Done)** 的專案。
- **自動清理**：
    - 主動偵測並還原環境造成的雜訊變更（如 `.python-version`, `setup_git_sync.ps1`），保持 Git 狀態潔淨。

---
*此協定適用於所有支援 Markdown 與 Context Loading 的 AI Agent (Cursor, Gemini, Claude, etc.)。*
