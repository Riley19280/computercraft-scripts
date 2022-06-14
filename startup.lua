function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end


 local id = os.getComputerID()

local startupScript = 'startup_scripts/'..id .. '_startup.lua'
local defaultStartupScript = 'startup_scripts/default.lua'

if file_exists(startupScript) then
    shell.run(startupScript)
elseif file_exists(defaultStartupScript) then
    shell.run(defaultStartupScript)
end
