from pathlib import Path

import pypdfium2 as pdfium

qmds = [q for q in Path(".").glob("*.qmd") if q.name != "README.qmd"]
if not qmds:
    raise SystemExit("no .qmd file found")

pdf_path = qmds[0].with_suffix(".pdf")
if not pdf_path.exists():
    raise SystemExit(f"{pdf_path} not found")

pdf = pdfium.PdfDocument(str(pdf_path))
page = pdf[0].render(scale=2).to_pil()
page.save("assets/img/preview.png", "PNG")
print("Preview saved to assets/img/preview.png")
