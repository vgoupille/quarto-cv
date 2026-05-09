import pypdfium2 as pdfium

pdf = pdfium.PdfDocument("template.pdf")
page = pdf[0].render(scale=2).to_pil()
page.save("assets/img/preview.png", "PNG")
print("Preview saved to assets/img/preview.png")
