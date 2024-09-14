local util = {}


function util.tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
	  if type(v) == "table" then
		print(formatting)
		util.tprint(v, indent+1)
	  elseif type(v) == 'boolean' then
		print(formatting .. tostring(v))
	  else
		print(formatting .. v)
	  end
	end
  end


function util.manhattanDistance(x1, y1, x2, y2)
	return math.abs(x2 - x1) + math.abs(y2 - y1)
end

function util.manhattanDistance3D(x1, y1, z1, x2, y2, z2)
	return math.abs(x2 - x1) + math.abs(y2 - y1) + math.abs(z2 - z1)
end

function util.table_has_value (table, value)
    for index, val in ipairs(table) do
        if value == val then
            return true
        end
    end

    return false
end

function util.clone_table(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[util.clone_table(k, s)] = util.clone_table(v, s) end
	return res
end

function util.chatMessage(msg)
	rednet.broadcast(msg, "to_chat")
end

-- A distribution is comprised of a table like so. Note distributions can be nested
-- {
-- 	{value=2, data="minecraft:stone"},
--     {value=1, data={
--         {value=1,data="minecraft:mossy_stone_bricks"},
--         {value=1,data="minecraft:polished_blackstone_bricks"},
--     	}
-- 	}
-- }
function util.getDistributionResult(distribution) 
	local selections = {}
    
    for i = 1, #distribution do
        for j = 1, distribution[i]['value'] do
            table.insert(selections, distribution[i]['data'])
        end
    end

    if #selections > 0 then
		local result = selections[math.random(#selections)]
        
        -- if resulting data is a table, then we will assume that it is another distribution 
        if type(result) == "table" then
            return util.getDistributionResult(result)
        else
            return result
        end
	else
		return nil
	end
end

return util

























