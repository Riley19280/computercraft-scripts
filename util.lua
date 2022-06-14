local util = {}

function util.detectDigUp() 
	while turtle.detectUp() do
		turtle.digUp()
	end
end

function util.detectDigDown() 
	while turtle.detectDown() do
		turtle.digDown()
	end
end

function util.detectDig() 
	while turtle.detect() do
		turtle.dig()
	end
end

function util.findItemInInventory(itemName) 
	local prevSelection = turtle.getSelectedSlot()
	
	local currentItem = turtle.getItemDetail()
	if currentItem and currentItem["name"] == itemName then
		return prevSelection
	end
	
	for i = 1, 16 do 
		turtle.select(i)
		local item = turtle.getItemDetail()
		if item and item["name"] == itemName then
			turtle.select(prevSelection)
			return i
		end
	end
	turtle.select(prevSelection)
	return nil
end


function util.placeBlock(blockName, direction)
	if not blockName then
		error("No blockName given to place")
	end

	local slot = util.findItemInInventory(blockName)
	
	if not slot then
		print("Block " .. blockName .. " not found in placeBlock")
		return false
	end
	
	turtle.select(slot)
	
	if direction == "up" then 
		return turtle.placeUp()
	elseif direction == "down" then 
		return turtle.placeDown()
	elseif direction == nil then
		return turtle.place()
	else
		error("Place direction " .. direction .. " is not defined")
	end
end

function util.placeBlockUp(blockName)
	return util.placeBlock(blockName, "up")
end

function util.placeBlockDown(blockName)
	return util.placeBlock(blockName, "down")
end


function util.isInventoryFull() 
	local selected = turtle.getSelectedSlot()
	
	for i = 1, 16 do
		turtle.select(i)
		local item = turtle.getItemDetail()
		
		if item == nil then
			turtle.select(selected)
			return false
		end
	end


	turtle.select(selected)
	return true
end

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

return util

























