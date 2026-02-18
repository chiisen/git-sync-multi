# ==============================================================================
# 腳本名稱: git-multi-pull.ps1
# 功能描述: 批次並行更新多個指定目錄內的 Git 倉庫並執行 git pull。
# ==============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string[]]$Paths = @(),
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Usage: .\git-multi-pull.ps1 [-Paths] <string[]> [-Help]

Description:
    批次並行更新多個指定目錄內的 Git 倉庫並執行 git pull。

Arguments:
    -Paths <string[]>    指定要更新的目錄路徑 (可多個，用逗號分隔)
    -Help               顯示此說明訊息

Examples:
    # 單一目錄
    .\git-multi-pull.ps1 -Paths 'D:\github\myrepo'

    # 多個目錄
    .\git-multi-pull.ps1 -Paths 'D:\github\repo1','D:\github\repo2','D:\github\repo3'

    # 透過環境變數 (在 .env 加入)
    # GIT_SYNC_PATHS="D:\repo1,D:\repo2"
    .\git-multi-pull.ps1

Environment:
    GIT_SYNC_PATHS      用逗號分隔的多個目錄路徑 (當未提供 -Paths 時使用)
    GITHUB_ACCOUNT     GitHub 帳號切換 (可選)
"@ -ForegroundColor Cyan
    exit 0
}

function Import-Env {
    param($Path = ".env")
    $envPath = Join-Path $PSScriptRoot $Path
    if (Test-Path $envPath) {
        $content = Get-Content $envPath -Raw
        $pattern = '(?m)^([^=#\s][^=]*)=(.*?)(?=\n[^=#\s][^=]*=|\z)'
        $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
        foreach ($match in $matches) {
            $name = $match.Groups[1].Value.Trim()
            $value = $match.Groups[2].Value.Trim().Trim('"').Trim("'")
            [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

Import-Env

if ($env:GITHUB_ACCOUNT) {
    Write-Host "切換 GitHub 帳號至: $env:GITHUB_ACCOUNT" -ForegroundColor Cyan
    gh auth switch -u $env:GITHUB_ACCOUNT 2>$null
}

Write-Host ">>> Git 多目錄同步工具" -ForegroundColor Yellow
Write-Host "功能：批次並行更新多個指定目錄內的 Git 倉庫。" -ForegroundColor Gray
Write-Host ""

$logDir = Join-Path $PSScriptRoot "logs"
$logPath = Join-Path $logDir "git_pull指定目錄_errors.log"

if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

$repos = @()

if ($Paths.Count -gt 0) {
    $repos = $Paths | ForEach-Object { Get-Item $_ -ErrorAction SilentlyContinue } | Where-Object { $_.PSIsContainer }
}
elseif ($env:GIT_SYNC_PATHS) {
    $repos = $env:GIT_SYNC_PATHS -split '[\r\n,]' | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Get-Item $_.Trim() -ErrorAction SilentlyContinue } | Where-Object { $_.PSIsContainer }
}
else {
    Write-Host "錯誤：請透過 -Paths 參數指定目錄，或設定環境變數 GIT_SYNC_PATHS" -ForegroundColor Red
    Write-Host "範例：.\git-multi-pull.ps1 -Paths 'D:\repo1','D:\repo2'" -ForegroundColor Yellow
    exit 1
}

$validRepos = $repos | Where-Object { Test-Path (Join-Path $_.FullName ".git") }
$totalRepoCount = $validRepos.Count

Write-Host "偵測到 $totalRepoCount 個 Git 倉庫，開始平行更新..." -ForegroundColor Cyan

"" | Out-File -FilePath $logPath -Encoding utf8

$throttleLimit = 5
$buffer = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

$executionTime = Measure-Command {
    $validRepos | ForEach-Object -Parallel {
        $dir = $_
        $buffer = $using:buffer
        $logPath = $using:logPath
        
        $output = git -C $dir.FullName pull 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            $errorMsg = "❌ [錯誤] 目錄: $($dir.FullName)`n原因: $output`n"
            Write-Host $errorMsg -ForegroundColor Red
            $buffer.Add($errorMsg)
        }
        else {
            Write-Host "✅ [成功] $($dir.FullName)" -ForegroundColor Green
        }
    } -ThrottleLimit $throttleLimit
}

if ($buffer.Count -gt 0) {
    $buffer | Out-File -FilePath $logPath -Append -Encoding utf8
}

$minutes = [Math]::Floor($executionTime.TotalMinutes)
$seconds = $executionTime.Seconds
Write-Host "`n全部處理完成！" -ForegroundColor Cyan
Write-Host "總計耗時: $minutes 分 $seconds 秒" -ForegroundColor Yellow
