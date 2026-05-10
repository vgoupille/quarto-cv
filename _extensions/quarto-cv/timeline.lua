-- timeline.lua: Convert Quarto ::: {.timeline} to Typst timeline-section
-- Supports optional "levels" attribute to specify which heading levels get dots
-- Example: ::: {.timeline levels="3"} or ::: {.timeline levels="3,4,5"}
function Div(el)
  if el.classes:includes("timeline") then
    -- Get the levels attribute (defaults to all levels 1-6 if not specified)
    local levels = el.attributes["levels"] or "1,2,3,4,5,6"
    
    -- Ensure trailing comma for Typst array syntax (single element needs trailing comma)
    if not levels:match(",$") then
      levels = levels .. ","
    end
    
    -- Wrap the content in #timeline-section(levels: (...))[...]
    local result = {}
    
    -- Opening tag with levels parameter
    table.insert(result, pandoc.RawBlock("typst", "#timeline-section(levels: (" .. levels .. "))["))
    
    -- Add all content blocks
    for _, block in ipairs(el.content) do
      table.insert(result, block)
    end
    
    -- Closing tag
    table.insert(result, pandoc.RawBlock("typst", "]"))
    
    return result
  end
  return el
end
