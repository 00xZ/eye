# 👁️ **Eye** — See More With an Extra Eye  
_All-in-one recon & low-hanging-fruit automation tool for bug hunters and web security researchers._

---

## 📸 Main Interface
![screenshot](https://github.com/00xZ/eye/blob/main/tools/main_eye.png?raw=true)

---

## ⚡ Quick Install
```bash
chmod +x *
./setup.sh
```

---

## 🧠 About `eye`
`eye` is a collection of automated recon and scanning workflows designed to speed up and simplify the initial stages of bug hunting. It links multiple tools together into a powerful chain, allowing you to focus on analysis rather than manual setup.

### 🔗 What It Does
- Performs automated recon and input-based vulnerability scanning  
- Uses several scripts and utilities together  
- Allows **custom exploit modules** under the:

```
vuln3()
```

function — you can add unlimited custom checks  

### 📂 Output Structure
All results are saved to:

```
output/NameOfTheSiteYouScanned.com/
```

---

## 🕹️ Usage

### 🔍 Scan Mode
```bash
./eye.sh --scan thewebsite.com
```

![screenshot](https://github.com/00xZ/eye/blob/main/tools/Screenshot%20(21).png?raw=true)

---

### 💥 Exploit Mode
```bash
./eye.sh --exploit thewebsite.com
```

---

### 🧩 Custom Exploit Mode
```bash
./eye.sh --custom thewebsite.com
```

![screenshot](https://github.com/00xZ/eye/blob/main/tools/Screenshot%20(23).png?raw=true)

---

## 🧱 Required Programs

To use `eye` fully, install the following tools:

- **gf** — https://github.com/tomnomnom/gf  
  - Templates: https://github.com/1ndianl33t/Gf-Patterns  
- **Gxss** — https://github.com/KathanP19/Gxss  
- **trashcompactor** — https://github.com/michael1026/trashcompactor  
- **dalfox** — https://github.com/hahwul/dalfox  
- **xray** — https://github.com/chaitin/xray  
- **anew** — https://github.com/tomnomnom/anew  
- **waymore** — https://github.com/xnl-h4ck3r/waymore  
- **dirsearch** — https://github.com/maurosoria/dirsearch  
- **qsreplace** — https://github.com/tomnomnom/qsreplace  
- **ghauri** — https://github.com/r0oth3x49/ghauri  
- **nuclei (+ templates)** — https://github.com/projectdiscovery/nuclei  
- **paramspider** — https://github.com/devanshbatham/ParamSpider  
- **httpx** — https://github.com/projectdiscovery/httpx  
- **parallel** — https://github.com/parallel-finance/parallel  
- **gdn** — https://github.com/kmskrishna/gdn  

---

## 🆕 Latest Updates
- **LFIscanner** — https://github.com/R3LI4NT/LFIscanner  
- **TPLmap** — https://github.com/epinna/tplmap  

---

## ⚠️ Legal Notice  
This tool is intended for **authorized, ethical security testing only**.  
Do NOT scan systems without proper permission.

---

## ⭐ Contributions & Support  
Suggestions, improvements, and issues are welcome.  
Let’s push `eye` to see even more. 👁️✨
LFIscanner ( https://github.com/R3LI4NT/LFIscanner )

TPLmap ( https://github.com/epinna/tplmap )
 
