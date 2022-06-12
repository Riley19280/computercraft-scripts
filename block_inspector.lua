
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

local success, data = turtle.inspect()

if success then
  print("Block name: ", data.name)
  print("Block metadata: ", data.metadata)
end


for i = 1,16 do
  if turtle.getItemCount(i) ~= 0 then
  print(i)
    return i
  end
end
