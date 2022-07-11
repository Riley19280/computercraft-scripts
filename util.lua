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

return util

























