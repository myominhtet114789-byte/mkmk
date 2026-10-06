#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════
#  mexOn Voucher Tool — Auto Installer
# ═══════════════════════════════════════════════════════════

set -e   # error တစ်ခုခုဆို ချက်ချင်း ရပ်

# ─── Colors ───
GREEN="\033[92m"
RED="\033[91m"
YELLOW="\033[93m"
BLUE="\033[94m"
CYAN="\033[96m"
RESET="\033[0m"

echo -e "${CYAN}═══════════════════════════════════════════════${RESET}"
echo -e "${CYAN}   mexOn Voucher Tool — Installer${RESET}"
echo -e "${CYAN}═══════════════════════════════════════════════${RESET}"

# ─── ၁။ Storage access ───
echo -e "\n${BLUE}[*]${RESET} Requesting storage access..."
termux-setup-storage || true
sleep 2

# ─── ၂။ Package update ───
echo -e "\n${BLUE}[*]${RESET} Updating packages..."
pkg update -y
pkg upgrade -y

# ─── ၃။ Python + Termux API ───
echo -e "\n${BLUE}[*]${RESET} Installing Python + Termux:API..."
pkg install -y python termux-api

# ─── ၄။ Python packages ───
echo -e "\n${BLUE}[*]${RESET} Installing Python packages..."
pip install --upgrade pip
pip install aiohttp requests

# ─── ၅။ Verify Python ───
echo -e "\n${BLUE}[*]${RESET} Verifying Python..."
python --version || { echo -e "${RED}❌ Python install failed${RESET}"; exit 1; }
python -c "import aiohttp; print('aiohttp', aiohttp.__version__)" || \
    { echo -e "${RED}❌ aiohttp install failed${RESET}"; exit 1; }

# ─── ၆။ Create folder ───
echo -e "\n${BLUE}[*]${RESET} Creating ~/mkmk ..."
rm -rf ~/mkmk
mkdir -p ~/mkmk
cd ~/mkmk

# ─── ၇။ Architecture detect ───
ARCH=$(getprop ro.product.cpu.abi)
echo -e "\n${BLUE}[*]${RESET} Detected architecture: ${YELLOW}${ARCH}${RESET}"

REPO="https://raw.githubusercontent.com/myominhtet114789-byte/mkmk/main"

case "$ARCH" in
    arm64-v8a|aarch64)
        SO_FILE="mkmk_64bit.so"
        ;;
    armeabi-v7a|armeabi)
        SO_FILE="mkmk_32bit.so"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unknown arch '${ARCH}' — trying 64-bit${RESET}"
        SO_FILE="mkmk_64bit.so"
        ;;
esac

# ─── ၈။ Download .so ───
echo -e "\n${BLUE}[*]${RESET} Downloading ${SO_FILE} ..."
if curl -fL -o mkmk.so "${REPO}/${SO_FILE}"; then
    echo -e "${GREEN}✅ Downloaded: mkmk.so${RESET}"
else
    echo -e "${RED}❌ Download failed: ${SO_FILE}${RESET}"
    exit 1
fi

# ─── ၉။ Verify .so ───
if [ ! -s mkmk.so ]; then
    echo -e "${RED}❌ mkmk.so is empty or missing${RESET}"
    exit 1
fi
SO_SIZE=$(stat -c%s mkmk.so 2>/dev/null || stat -f%z mkmk.so)
echo -e "${GREEN}✅ File size: ${SO_SIZE} bytes${RESET}"

# ─── ၁၀။ Download runner ───
echo -e "\n${BLUE}[*]${RESET} Downloading runner..."
if curl -fL -o mkmk_run.py "${REPO}/mkmk_run.py"; then
    echo -e "${GREEN}✅ Downloaded: mkmk_run.py${RESET}"
else
    echo -e "${RED}❌ Runner download failed${RESET}"
    exit 1
fi

# ─── ၁၁။ Final check ───
echo -e "\n${BLUE}[*]${RESET} Files in ~/mkmk:"
ls -lh ~/mkmk/

# ─── ၁၂။ Success ───
echo -e "\n${CYAN}═══════════════════════════════════════════════${RESET}"
echo -e "${GREEN}✅ Installation complete!${RESET}"
echo -e "${CYAN}═══════════════════════════════════════════════${RESET}"
echo -e "\n${YELLOW}အသုံးပြုရန်:${RESET}"
echo -e "   ${CYAN}cd ~/mkmk && python mkmk_run.py${RESET}\n"
