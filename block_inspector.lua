
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
