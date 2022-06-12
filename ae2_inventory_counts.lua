local start = os.clock()
local me = peripheral.wrap("back")
local items = me.getAvailableItems("ALL")

--items = {unpack(items, 1, 10)}

local baseurl = "http://stats.rileystech.com:9090"
local logurl = baseurl.."/log"
local aedataurl = baseurl.."/aeitems"


function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function try(f, catch_f)
	local status, exception = pcall(f)
	if not status then
		catch_f(exception)
	end
end


function netlog(text)
  http.post(logurl, text)
end

aedata = {}
aestr = ""


function item_to_key(item)
	local displayname = item["item"]["display_name"]
	local keyname, ct = string.gsub(displayname, ":", "_")
	keyname, ct = string.gsub(keyname, "[^a-zA-Z0-9 _-]", "")
	keyname, ct = string.gsub(keyname, " ", "_")
	return keyname
end

function detailandappend(i)
	local keyname = item_to_key(i)
	
	if aedata[keyname] == nil then
	  aedata[keyname] = i["size"]
	else
	  aedata[keyname] = aedata[keyname] + i["size"]
	end
end

function run()
	
	for ik, i in pairs(items) do
		
		local status, exception = pcall(detailandappend, i)
		if not status then
			if exception == "Terminated" then
				error("Terminated")
			end
		
			netlog("Exception: "..exception)
			netlog("exception ik: "..dump(ik))
			netlog("exception i: "..dump(i))
		end
		--print(detail["display_name"].." "..detail["qty"])
	end
	for k,v in pairs(aedata) do
		aestr  = aestr..k..","..v.."\n"
	end
	local timediff=  os.clock()-start
	netlog(aestr)
	
	local headers = {
	  [ "Execution-Time" ] = tostring(timediff)
	}
	
	http.post(aedataurl, aestr, headers)
	
	print("Item Count: "..tablelength(aedata))
	print("Time: "..timediff)
	--netlog(aestr)
	
end

print("Raw Item Count: "..tablelength(items))
run()
