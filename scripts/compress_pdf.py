import re
import yaml
from datetime import date
from pathlib import Path

import pikepdf


def target_pdf(qmd: Path) -> Path | None:
    content = qmd.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None

    fm = yaml.safe_load(match.group(1))
    author = str(fm.get("author", "")).strip()
    if not author:
        return None

    name = "_".join(author.split())

    raw_date = fm.get("date", "")
    try:
        doc_date = date.fromisoformat(str(raw_date))
    except (ValueError, TypeError):
        doc_date = date.today()
    formatted_date = doc_date.strftime("%Y-%m-%d")

    return Path(f"CV_{name}_{formatted_date}.pdf")


def compress(pdf: Path) -> None:
    before = pdf.stat().st_size
    tmp = pdf.with_suffix(".tmp.pdf")

    with pikepdf.open(pdf) as doc:
        doc.save(
            tmp,
            compress_streams=True,
            object_stream_mode=pikepdf.ObjectStreamMode.generate,
            recompress_flate=True,
        )

    after = tmp.stat().st_size
    if after < before:
        tmp.replace(pdf)
        pct = round((1 - after / before) * 100)
        print(f"  compressed {pdf.name}: {before // 1024} KB → {after // 1024} KB (-{pct}%)")
    else:
        tmp.unlink()
        print(f"  {pdf.name}: already optimal, skipped")


for qmd in Path(".").glob("*.qmd"):
    if qmd.name == "README.qmd":
        continue
    pdf = target_pdf(qmd)
    if pdf and pdf.exists():
        compress(pdf)
