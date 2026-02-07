# 定義載入 .env 的函式
function Load-Env {
    param($Path = ".env")
    $envPath = Join-Path $PSScriptRoot $Path
    if (Test-Path $envPath) {
        Get-Content $envPath | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
            $parts = $_.Split('=', 2)
            if ($parts.Count -eq 2) {
                $name = $parts[0].Trim()
                $value = $parts[1].Trim().Trim('"').Trim("'")
                [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    }
}

# 執行載入
Load-Env

# 設定搜尋的根目錄 (優先從環境變數取得)
$rootPath = if ($env:ROOT_PATH) { $env:ROOT_PATH } else { "D:\github\chiisen\" }
$logPath = Join-Path $PSScriptRoot "git_status_changed.log"

$startTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$startMsg = "--- Git Status Check Start: $startTime ---`n掃描根目錄: $rootPath"
Write-Host "開始檢查 git status (有異動的目錄): $rootPath ..." -ForegroundColor Cyan

# 記錄開始資訊到 Log
"$startMsg`n" | Out-File -FilePath $logPath -Encoding utf8

# 取得所有子目錄
$directories = Get-ChildItem -Path $rootPath -Directory

$changedCount = 0
$totalCount = 0

foreach ($dir in $directories) {
    $gitDir = Join-Path $dir.FullName ".git"
    
    # 檢查是否為 Git 倉庫
    if (Test-Path $gitDir) {
        $totalCount++
        # 執行 git status --porcelain
        $status = git -C $dir.FullName status --porcelain 2>$null
        
        if ($status) {
            $changedCount++
            $msg = "📍 [有異動] $($dir.Name)"
            Write-Host $msg -ForegroundColor Yellow
            
            # 寫入 Log 分隔線與具體異動內容
            "[$($dir.Name)] ($($dir.FullName))`n$($status -join "`n")`n" | Out-File -FilePath $logPath -Append -Encoding utf8
        }
    }
}

$endTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$summaryMsg = "--- 檢查完成 ($endTime) ---`n總計掃描專案數: $totalCount`n有異動的專案數: $changedCount"

# 記錄結束總結到 Log
"`n$summaryMsg" | Out-File -FilePath $logPath -Append -Encoding utf8

Write-Host "`n$summaryMsg" -ForegroundColor Cyan
if ($changedCount -gt 0) {
    Write-Host "細節請查看 Log: $logPath" -ForegroundColor Yellow
} else {
    Write-Host "所有專案皆為乾淨狀態 (Clean)。" -ForegroundColor Green
}

