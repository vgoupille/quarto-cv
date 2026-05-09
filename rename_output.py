import re
import yaml
from datetime import date
from pathlib import Path

qmd = Path("template.qmd")
if not qmd.exists():
    raise SystemExit(0)

content = qmd.read_text(encoding="utf-8")
match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
if not match:
    raise SystemExit(0)

fm = yaml.safe_load(match.group(1))
author = str(fm.get("author", "")).strip()
if not author:
    raise SystemExit(0)

name = "_".join(author.split())

raw_date = fm.get("date", "")
try:
    doc_date = date.fromisoformat(str(raw_date))
except (ValueError, TypeError):
    doc_date = date.today()
formatted_date = doc_date.strftime("%Y-%m-%d")

src = Path("template.pdf")
dst = Path(f"CV_{name}_{formatted_date}.pdf")
if src.exists():
    src.rename(dst)
    print(f"  → {dst}")
