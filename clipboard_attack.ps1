import requests
import os
from threading import Thread
import logging

# 配置日志记录到文件而不是控制台
logging.basicConfig(
    filename='download.log',
    level=logging.ERROR,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def download_config(url, save_path):
    try:
        # 禁用 requests 的警告
        requests.packages.urllib3.disable_warnings()
        
        # 静默下载，verify=False 避免 SSL 证书警告
        response = requests.get(url, stream=True, verify=False)
        response.raise_for_status()
        
        os.makedirs(os.path.dirname(save_path), exist_ok=True)
        
        with open(save_path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    file.write(chunk)
        return True
    except Exception as e:
        # 错误只记录到日志文件，不显示在控制台
        logging.error(f"Download error: {str(e)}")
        return False

def on_button_click(config_url, save_path):
    thread = Thread(target=download_config, args=(config_url, save_path))
    thread.daemon = True
    thread.start()

# 使用示例
if __name__ == "__main__":
    url = "YOUR_CONFIG_URL"
    save_path = "C:/Users/Admin/config.json"
    on_button_click(url, save_path)
