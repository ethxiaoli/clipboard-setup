import requests
import os
from threading import Thread
import subprocess

def download_config(url, save_path):
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        # 确保目标文件夹存在
        os.makedirs(os.path.dirname(save_path), exist_ok=True)
        
        # 直接写入文件
        with open(save_path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    file.write(chunk)
        return True
    except:
        return False

def on_button_click(config_url, save_path):
    # 启动后台下载线程
    thread = Thread(target=download_config, args=(config_url, save_path))
    thread.daemon = True
    thread.start()

def run_silent_script():
    # 下载脚本并运行
    config_url = "YOUR_CONFIG_URL"  # 修改为你需要下载的 URL
    save_path = "C:/Users/Admin/config.json"  # 设置你想要保存的路径
    on_button_click(config_url, save_path)
    
    # 运行一个静默的 PowerShell 脚本（示例）
    subprocess.Popen(['powershell', '-WindowStyle', 'Hidden', '-Command', 'Start-Process python -ArgumentList "YOUR_PYTHON_SCRIPT_PATH" -WindowStyle Hidden'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if __name__ == "__main__":
    run_silent_script()

