import re
import shutil
import yaml
from datetime import date
from pathlib import Path


def process_qmd(qmd: Path) -> None:
    content = qmd.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return

    fm = yaml.safe_load(match.group(1))
    author = str(fm.get("author", "")).strip()
    if not author:
        return

    name = "_".join(author.split())

    raw_date = fm.get("date", "")
    try:
        doc_date = date.fromisoformat(str(raw_date))
    except (ValueError, TypeError):
        doc_date = date.today()
    formatted_date = doc_date.strftime("%Y-%m-%d")

    src = qmd.with_suffix(".pdf")
    dst = Path(f"CV_{name}_{formatted_date}.pdf")
    if src.exists():
        shutil.copy2(src, dst)
        print(f"  → {dst}")


for qmd in Path(".").glob("*.qmd"):
    if qmd.name == "README.qmd":
        continue
    process_qmd(qmd)
