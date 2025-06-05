local indent = 4
function serialize(table, indentLevel)
  indentLevel = indentLevel or 0
  local str = "{"
  local ind = string.rep(" ", (indentLevel + 1) * indent)
  for k, v in pairs(table) do
    str = str .. "\n" .. ind
    if type(k) == "string" then
      str = str .. k
    elseif type(k) == "number" then
      str = str .. "[" .. tostring(k) .. "]"
    else
      error(("Unable to serialize key: %s (%s)"):format(k, type(k)))
    end
    str = str .. " = "
    if type(v) == "string" then
      str = str .. '"' .. v .. '"'
    elseif type(v) == "boolean" or type(v) == "number" then
      str = str .. tostring(v)
    elseif type(v) == "table" then
      str = str .. serialize(v, indentLevel + 1)
    else
      error(("Unable to serialize value: %s (%s)"):format(v, type(v)))
    end
    if next(table, k) then
      str = str .. ","
    end
  end
  str = str .. "\n" .. string.rep(" ", indentLevel * indent) .. "}"
  return str
end

function deserialize(str)
  local s, e = pcall(loadstring, "return " .. str)
  if not s then
    error(("Error while deserializing string %q: %s"):format(str, e))
  end
  return e()
end