-- captions.lua: Render table captions for Typst output (above table, numbered)
-- Pandoc doesn't pass captions through the Typst template, so we extract
-- them from the AST and emit styled Typst text blocks manually.

local table_counter = 0

local function caption_block(n, text)
  return pandoc.RawBlock("typst", string.format(
    '#align(center)[#text(size: 8pt, weight: "semibold")[Table %d — ]#text(size: 8pt, style: "italic", fill: rgb("#64748b"))[%s]]\n#v(0.2em)',
    n, text
  ))
end

function Table(el)
  if not FORMAT:match("typst") then return el end

  local caption = el.caption
  if not caption or not caption.long or #caption.long == 0 then return el end

  table_counter = table_counter + 1
  local text = pandoc.utils.stringify(caption.long)
  el.caption.long = pandoc.List({})

  return {
    caption_block(table_counter, text),
    pandoc.RawBlock("typst", "#align(center)["),
    el,
    pandoc.RawBlock("typst", "]"),
  }
end
