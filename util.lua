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


return util


























