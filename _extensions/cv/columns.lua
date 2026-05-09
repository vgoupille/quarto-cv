-- columns.lua: Convert Quarto ::: {.columns} to Typst grid
function Div(el)
  if el.classes:includes("columns") then
    -- Collect column children
    local cols = {}
    for _, block in ipairs(el.content) do
      if block.t == "Div" and block.classes:includes("column") then
        -- Extract width if specified
        local width = block.attributes["width"] or "1fr"
        table.insert(cols, {width = width, content = block.content})
      end
    end
    
    if #cols > 0 then
      -- Build Typst grid
      local widths = {}
      local contents = {}
      for i, col in ipairs(cols) do
        -- Convert percentage to fr if needed
        local w = col.width
        if w:match("%%$") then
          w = (tonumber(w:match("(%d+)")) / 100) .. "fr"
        end
        table.insert(widths, w)
        table.insert(contents, pandoc.RawBlock("typst", "["))
        for _, b in ipairs(col.content) do
          table.insert(contents, b)
        end
        table.insert(contents, pandoc.RawBlock("typst", "],"))
      end
      
      -- Remove trailing comma from last content
      contents[#contents] = pandoc.RawBlock("typst", "]")
      
      local header = pandoc.RawBlock("typst", 
        "#grid(\n  columns: (" .. table.concat(widths, ", ") .. "),\n  gutter: 1em,")
      local footer = pandoc.RawBlock("typst", ")")
      
      local result = {header}
      for _, c in ipairs(contents) do
        table.insert(result, c)
      end
      table.insert(result, footer)
      
      return result
    end
  end
  return el
end
