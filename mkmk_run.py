#!/usr/bin/env python3
"""
Runner for mk31.so
- .so file ကို auto import
- main() ကို auto run
- Errors ကို ရှင်းရှင်းလင်းလင်း ပြ
"""

import os
import sys
import glob
import asyncio
import traceback

# ═══════════════════════════════════════════════════════════
#  Config
# ═══════════════════════════════════════════════════════════
MODULE_NAME = "mkmk"          # ← .so file ရဲ့ base name
HERE = os.path.dirname(os.path.abspath(__file__))

# Colors
GREEN  = "\033[1;32m"
RED    = "\033[1;31m"
YELLOW = "\033[1;33m"
BLUE   = "\033[1;34m"
CYAN   = "\033[1;36m"
BOLD   = "\033[1m"
RESET  = "\033[0m"


# ═══════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════
def show_banner():
    print(f"{CYAN}═══════════════════════════════════════════════════════════════{RESET}")
    print(f"{CYAN}   mexOn Voucher Tool — Runner (.so){RESET}")
    print(f"{CYAN}═══════════════════════════════════════════════════════════════{RESET}")


def find_so_files():
    """Folder ထဲမှာ .so file အားလုံး ရှာ"""
    return sorted(glob.glob(os.path.join(HERE, "*.so")))


def try_import(name):
    """Module ကို import ကြိုးစား။ (module, error) ပြန်။"""
    try:
        sys.path.insert(0, HERE)
        module = __import__(name)
        return module, None
    except ImportError as e:
        return None, e
    except Exception as e:
        return None, e


def list_functions(module):
    """Module ထဲက public functions / classes"""
    items = []
    for x in dir(module):
        if x.startswith("_"):
            continue
        items.append(x)
    return items


# ═══════════════════════════════════════════════════════════
#  Main
# ═══════════════════════════════════════════════════════════
def main():
    show_banner()

    # ─── ၁။ .so file ရှိလား စစ် ───
    so_files = find_so_files()
    if not so_files:
        print(f"{RED}❌ ဒီ folder ထဲမှာ .so file မတွေ့ပါ{RESET}")
        print(f"{YELLOW}   Folder: {HERE}{RESET}")
        print(f"\n{BLUE}💡 .so file ကို ဒီ folder ထဲ ထည့်ပါ{RESET}")
        sys.exit(1)

    print(f"{BLUE}[*]{RESET} .so files တွေ့တယ် ({len(so_files)}):")
    for f in so_files:
        print(f"    • {os.path.basename(f)}")
    print()

    # ─── ၂။ Module import ───
    print(f"{BLUE}[*]{RESET} Importing '{MODULE_NAME}'...")
    module, err = try_import(MODULE_NAME)

    if module is None:
        print(f"{RED}❌ Import failed: {err}{RESET}\n")

        # ─── Name အလိုက် auto-fix ───
        print(f"{YELLOW}💡 .so name ကို '{MODULE_NAME}.so' လို့ ပြောင်းပါ:{RESET}")
        for f in so_files:
            base = os.path.basename(f)
            print(f"   {BLUE}mv \"{base}\" \"{MODULE_NAME}.so\"{RESET}")
        print()

        # ဖြစ်နိုင်တဲ့ name တွေ စမ်း
        print(f"{BLUE}[*]{RESET} Auto-detect တွေ စမ်းနေသည်...")
        for f in so_files:
            base = os.path.basename(f)
            # .cpython-XX.so အပိုင်း ဖျောက်
            guess = base.split(".")[0]
            print(f"    Trying: {guess}")
            mod2, err2 = try_import(guess)
            if mod2 is not None:
                print(f"{GREEN}✅ Found: '{guess}'{RESET}\n")
                module = mod2
                break

        if module is None:
            print(f"{RED}❌ Auto-detect မအောင်မြင်ပါ။{RESET}")
            print(f"\n{YELLOW}Manual fix:{RESET}")
            print(f"   cd {HERE}")
            print(f"   mv \"{os.path.basename(so_files[0])}\" \"{MODULE_NAME}.so\"")
            print(f"   python run.py")
            sys.exit(1)

    print(f"{GREEN}✅ Imported: {module.__name__}{RESET}\n")

    # ─── ၃။ Functions စစ် ───
    funcs = list_functions(module)
    print(f"{BLUE}[*]{RESET} Available: {', '.join(funcs[:15])}")
    if len(funcs) > 15:
        print(f"    ... +{len(funcs)-15} more")
    print()

    # ─── ၄။ main() ရှာပြီး run ───
    if not hasattr(module, "main"):
        print(f"{RED}❌ 'main' function မတွေ့ပါ{RESET}")
        print(f"{YELLOW}   Available: {funcs}{RESET}")
        sys.exit(1)

    print(f"{BLUE}[*]{RESET} Starting main()...\n")
    print(f"{CYAN}{'═' * 63}{RESET}")

    try:
        # async main() လား၊ sync main() လား စစ်
        result = module.main()
        if asyncio.iscoroutine(result):
            asyncio.run(result)
        else:
            # sync main ဖြစ်ရင် တိုက်ရိုက် ပြီးသွား
            pass
    except KeyboardInterrupt:
        print(f"\n\n{YELLOW}⚠️  Interrupted by user (Ctrl+C){RESET}")
    except Exception as e:
        print(f"\n\n{RED}❌ Error in main():{RESET}")
        print(f"{RED}{e}{RESET}\n")
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}⚠️  Interrupted{RESET}")
    except SystemExit:
        raise
    except Exception as e:
        print(f"\n{RED}❌ Runner error: {e}{RESET}")
        traceback.print_exc()