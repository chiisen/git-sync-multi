# Gemini 全域配置指南 (GEMINI_GLOBAL_SETUP.md)

本文件建議將 `AI_AGENT_PROTOCOL.md` 的核心內容整合至 Gemini (或任何支援 System Instructions 的 AI 工具) 的全域設定中，以達成最佳協作效果。

## 🎯 為什麼選擇 Rule (全域規則) 而非 Workflow？

針對 **Gemini** 作為主力 AI 的情境，我們強烈建議採用 **Rule (User Rules / System Instructions)** 模式：

1.  **無縫觸發 (Zero Friction)**：
    - Gemini 擅長理解並遵循全域指令。一旦設定為 Rule，您**無需手動觸發**任何流程，Gemini 在開啟新對話或新專案時，會自動套用標頭規範、平行處理邏輯與帳號檢查機制。
    
2.  **靈活應變 (Adaptive Intelligence)**：
    - Workflow 通常是固定步驟 (Step 1 -> 2 -> 3)，缺乏彈性。
    - Rule 賦予 Gemini 「**精神指導**」。例如：當它偵測到新專案結構混亂時，會主動提議：「檢測到缺乏開發規範，是否建立 `GEMINI.md`？」

3.  **降低 Context 成本**：
    - Rule 是一次性設定，永久生效，不需要每次對話重複輸入指令或 Context。

---

## 🛠️ 設定步驟 (Action Plan)

請將 `AI_AGENT_PROTOCOL.md` 的內容，複製並貼入以下位置：

- **Gemini (Web / API)**: System Instructions 或 Custom Instructions 欄位。
- **Cursor (IDE)**: `.cursorrules` (專案級) 或 Global Rules (全域設定)。
- **VS Code Copilot**: Custom Instructions (若支援)。

### ✅ 預期效果
設定完成後，您的 Gemini 將具備以下行為模式：

- **開新專案時**：主動詢問是否建立 `GEMINI.md` 來規範開發流程。
- **撰寫腳本時**：自動添加標準 **標頭註解** 與 **啟動提示**，並優先使用 `ForEach-Object -Parallel` 撰寫高效能代碼。
- **遇到權限問題時**：優先檢查 `.env` 並建議執行 `gh auth switch`，而非盲目重試。

---
*將規則內化為 AI 的本能，是提升人機協作效率的關鍵。*
