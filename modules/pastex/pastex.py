#!/usr/bin/env python3
import os, sys, shutil, re, subprocess, platform
from pathlib import Path

def get_clipboard():
    sys_name = platform.system()
    if "microsoft" in platform.release().lower() or sys_name == "Windows":
        try: return subprocess.check_output(["powershell.exe", "-NoProfile", "-Command", "Get-Clipboard"], text=True).strip()
        except: pass
    if os.environ.get("WAYLAND_DISPLAY") and shutil.which("wl-paste"):
        return subprocess.check_output(["wl-paste"], text=True)
    if shutil.which("xclip"):
        return subprocess.check_output(["xclip", "-o"], text=True)
    if shutil.which("termux-clipboard-get"):
        return subprocess.check_output(["termux-clipboard-get"], text=True)
    sys.exit(1)

def main():
    try: content = get_clipboard()
    except: sys.exit(1)

    header = "# @pastex"
    if header not in content: sys.exit(0)

    repo_root = Path(os.getcwd())
    parts = re.split(f'(?={re.escape(header)} file:)', content)
    
    for p in parts:
        if header not in p: continue
        lines = p.strip().splitlines()
        meta = {}
        for line in lines[:20]:
            if not line.strip().startswith(header): continue
            if ":" in line:
                k,v = line.replace(header,"").strip().split(":",1)
                meta[k.strip()] = v.strip()
        
        if "file" not in meta: continue
        fpath = repo_root / meta["file"]
        fpath.parent.mkdir(parents=True, exist_ok=True)
        with open(fpath, "w") as f:
            if "shebang" in meta: f.write(f"#!{meta['shebang']}\n")
            f.write(p.strip() + "\n")
        fpath.chmod(0o755)
        if meta.get("exec"): os.system(meta["exec"].replace("%f", str(fpath)))

if __name__ == "__main__": main()
