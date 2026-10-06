#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════
#   Mikrotik Router Test — Auto Installer
# ═══════════════════════════════════════════════════════════

echo -e "\033[96m═══════════════════════════════════════════════\033[0m"
echo -e "\033[96m      Mikrotik Router Test — Installer        \033[0m"
echo -e "\033[96m═══════════════════════════════════════════════\033[0m"

echo -e "\n\033[92m[*] mikrotik_voucher အား ထည့်သွင်းနေပါသည်...\033[0m"

# ─── ၀။ Storage access ───
echo -e "\033[94m[*] Storage permission တောင်းခံနေသည်...\033[0m"
termux-setup-storage
sleep 2

# ─── ၁။ လိုအပ်တဲ့ Python နဲ့ Library တွေ သွင်းမယ် ───
echo -e "\033[94m[*] Packages update လုပ်နေသည်...\033[0m"
pkg update && pkg upgrade -y

echo -e "\033[94m[*] Python + Termux:API + Tools သွင်းနေသည်...\033[0m"
pkg install -y python python-dev pip termux-api curl wget openssl libffi

echo -e "\033[94m[*] Python packages သွင်းနေသည်...\033[0m"
pip install --upgrade pip
pip install requests aiohttp

# ─── ၂။ Folder အဟောင်းရှိရင် ဖျက်ပြီး အသစ်ဆောက်မယ် ───
rm -rf ~/mkmk
mkdir -p ~/mkmk
cd ~/mkmk

# ─── ၃။ ဖုန်းရဲ့ Bit (Architecture) ကို စစ်ဆေးမယ် ───
ARCH=$(getprop ro.product.cpu.abi)

if [ "$ARCH" = "arm64-v8a" ]; then
    echo -e "\033[94m[*] 64-bit ဖုန်းဖြစ်ကြောင်း စစ်ဆေးတွေ့ရှိရသဖြင့် 64-bit version ကို ဒေါင်းလုဒ်ဆွဲနေသည်...\033[0m"
    curl -LO https://raw.githubusercontent.com/myominhtet114789-byte/mkmk/main/mkmk_64bit.so
    mv mkmk_64bit.so mkmk.so
else
    echo -e "\033[94m[*] 32-bit ဖုန်းဖြစ်ကြောင်း စစ်ဆေးတွေ့ရှိရသဖြင့် 32-bit version ကို ဒေါင်းလုဒ်ဆွဲနေသည်...\033[0m"
    curl -LO https://raw.githubusercontent.com/myominhtet114789-byte/mkmk/main/mkmk_32bit.so
    mv mkmk_32bit.so mkmk.so
fi

# ─── ၄။ Starter ဖိုင်ကို ဒေါင်းမယ် ───
curl -LO https://raw.githubusercontent.com/myominhtet114789-byte/mkmk/main/mkmk_run.py

# ─── ၅။ Verify ───
echo -e "\n\033[94m[*] ဖိုင်များ စစ်ဆေးနေသည်...\033[0m"
ls -lh ~/mkmk/

echo -e "\033[92m[✔] အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ!\033[0m"
echo -e "\033[93mအသုံးပြုရန်: cd ~/mkmk && python mkmk_run.py\033[0m"
