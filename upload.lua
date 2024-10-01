local args = {...}

local path = ''
if args[1] then
    path = args[1] .. '/'
end

print('Saving files to ' .. path .. '<filename>')

while true do
    local _, files = os.pullEvent("file_transfer")
    for _, file in ipairs(files.getFiles()) do
      local savePath = path .. file.getName()
      local handle = fs.open(savePath, "wb")

      handle.write(file.readAll())
    
      handle.close()
      file.close()
      
      print('File saved to ' .. savePath)
    end
end