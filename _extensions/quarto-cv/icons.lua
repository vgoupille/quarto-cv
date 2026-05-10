-- Read SVG icon files relative to this filter's location and inject as
-- Typst string metadata, avoiding path resolution issues across namespaces.
function Meta(meta)
  local dir = PANDOC_SCRIPT_FILE:match("(.*[/\\])")
  local names = {"phone","email","birthdate","city","nationality","permit","website","linkedin","github"}
  meta["cv-icons"] = {}
  for _, name in ipairs(names) do
    local f = io.open(dir .. "icons/" .. name .. ".svg", "r")
    if f then
      local content = f:read("*all")
      f:close()
      content = content:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
      meta["cv-icons"][name] = pandoc.MetaInlines{pandoc.RawInline("typst", '"' .. content .. '"')}
    end
  end
  return meta
end
