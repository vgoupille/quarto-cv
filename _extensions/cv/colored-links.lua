-- Lua filter for Quarto/Pandoc to support colored links with {color="..."}
-- Usage: [Link text](url){color="#hexcode"}

function Link(el)
  -- Check if the link has a color attribute
  local color = el.attributes["color"]
  
  if color then
    -- Remove the color attribute so it doesn't appear in output
    el.attributes["color"] = nil
    
    -- For Typst output: wrap the link in a text with fill color
    if FORMAT:match("typst") then
      -- Create the Typst raw block with colored link
      local typst_code = string.format(
        '#text(fill: rgb("%s"))[#link("%s")[%s]]',
        color,
        el.target,
        pandoc.utils.stringify(el.content)
      )
      return pandoc.RawInline("typst", typst_code)
    end
  end
  
  return el
end
