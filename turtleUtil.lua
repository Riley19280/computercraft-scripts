util = require('util')

turtle.findBlacklist = {}

function turtle.detectDigUp() 
	while turtle.detectUp() do
		turtle.digUp()
	end
end

function turtle.detectDigDown() 
	while turtle.detectDown() do
		turtle.digDown()
	end
end

function turtle.detectDig() 
	while turtle.detect() do
		turtle.dig()
	end
end

function turtle.findItem(itemName) 
	for i = 1, 16 do
		local item = turtle.getItemDetail(i)
		if item and item["name"] == itemName then
			return i
		end
	end
	return nil
end


function turtle.findAnyItem() 
	local currentItem = turtle.getItemDetail()
	if currentItem and not util.table_has_value(turtle.findBlacklist, currentItem["name"]) then
		return turtle.getSelectedSlot()
	end
	
	for i = 1, 16 do 
		local item = turtle.getItemDetail(i)
		if item and not util.table_has_value(turtle.findBlacklist, item["name"]) then
			return i
		end
	end
	return nil
end


function turtle.findRandomItem() 
	local items = {}
	
	for i = 1, 16 do 
		local item = turtle.getItemDetail(i)
		if item and not util.table_has_value(turtle.findBlacklist, item["name"]) then
			table.insert(items, i)
		end
	end

	if #items > 0 then
		return items[math.random(#items)]
	else
		return nil
	end
end


function turtle.placeBlock(blockName, direction)
	if not blockName then
		error("No blockName given to place")
	end

	local slot = turtle.findItem(blockName)
	
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

function turtle.placeBlockUp(blockName)
	return turtle.placeBlock(blockName, "up")
end

function turtle.placeBlockDown(blockName)
	return turtle.placeBlock(blockName, "down")
end


function turtle.isInventoryFull() 
	for i = 1, 16 do
		if turtle.getItemDetail(i) == nil then
			return false
		end
	end
	return true
end