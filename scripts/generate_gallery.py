"""
Render example.qmd with each built-in theme and save the first page as
assets/img/preview-{theme}.png.

Usage:
    uv run scripts/generate_gallery.py
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

import pypdfium2 as pdfium

THEMES = ["classic-blue", "forest-green", "minimal-dark", "warm-terracotta"]
SOURCE = Path("example.qmd")
OUT_DIR = Path("assets/img")


def set_active_theme(content: str, theme: str) -> str:
    """Ensure only the target theme line is active in metadata-files."""
    lines = content.splitlines()
    result = []
    for line in lines:
        active = re.match(r"^\s+- themes/([\w-]+)\.yml", line)
        commented = re.match(r"^\s+#\s*-\s*themes/([\w-]+)\.yml", line)
        if active:
            t = active.group(1)
            if t == theme:
                result.append(line)
            else:
                result.append(re.sub(r"(\s+)- (themes/)", r"\1# - \2", line))
        elif commented:
            t = commented.group(1)
            if t == theme:
                result.append(re.sub(r"(\s+)#\s*- (themes/)", r"\1- \2", line))
            else:
                result.append(line)
        else:
            result.append(line)
    return "\n".join(result)


def cleanup(stem: str) -> None:
    Path(f"{stem}.qmd").unlink(missing_ok=True)
    Path(f"{stem}.pdf").unlink(missing_ok=True)
    Path(f"{stem}.typ").unlink(missing_ok=True)
    files_dir = Path(f"{stem}_files")
    if files_dir.exists():
        shutil.rmtree(files_dir)
    # post-render hooks copy PDFs for every QMD in root — clean them all
    for f in Path(".").glob("CV_*.pdf"):
        f.unlink(missing_ok=True)


def main() -> None:
    if not SOURCE.exists():
        sys.exit(f"{SOURCE} not found — run from the project root")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    original = SOURCE.read_text(encoding="utf-8")

    for theme in THEMES:
        print(f"\n=== {theme} ===")
        stem = f"_gallery_{theme}"
        tmp_qmd = Path(f"{stem}.qmd")
        tmp_pdf = Path(f"{stem}.pdf")

        try:
            tmp_qmd.write_text(set_active_theme(original, theme), encoding="utf-8")

            result = subprocess.run(
                ["quarto", "render", str(tmp_qmd)],
                capture_output=True,
                text=True,
            )
            if result.returncode != 0:
                print(result.stderr)
                sys.exit(f"quarto render failed for {theme}")

            if not tmp_pdf.exists():
                sys.exit(f"{tmp_pdf} not found after render")

            doc = pdfium.PdfDocument(str(tmp_pdf))
            page = doc[0].render(scale=2).to_pil()
            out_path = OUT_DIR / f"preview-{theme}.png"
            page.save(str(out_path), "PNG")
            print(f"Saved {out_path}")

        finally:
            cleanup(stem)


if __name__ == "__main__":
    main()
