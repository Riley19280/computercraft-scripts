util = require('util')

_G['util'] = util

function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

rednet.open("right")

print("Listening for rednet commands")

while true do
	local senderId, msg, protocol = rednet.receive("miners")

	local args = split(msg)
	local method = args[1]
	
	if method == "exec" then 
		print("Recieved and executing " .. args[2])
		table.remove(args, 1)
		if not pcall(shell.run(unpack(args))) then
			print('encountered error')
		end
	else
		local cmd = table.concat(args, " ")
		print("Recieved code to run: " .. cmd)
		
		local fn = loadstring(cmd)
		
		fn()
		
		if fn then 
			if not pcall(fn) then
				print('encountered error')
			end
		else
			print('encountered error')
		end
	
		
	end

end