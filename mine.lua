util = require('util')
local args = {...}
local distance = args[1]
local height = args[2] or 3

local chestName = "enderstorage:ender_chest"
local fillerBlock = "minecraft:netherrack"


function dumpInventory() 
	local chest = util.findItemInInventory(chestName)
	
	if not chest then 
		print("No chest found to dump inventory")
		return
	end

	util.detectDigUp()
	turtle.select(chest)
	turtle.placeUp()
	
	local fillerFound = false
	
	for i = 1, 16 do 
		turtle.select(i)
		local item = turtle.getItemDetail()
		if item and item["name"] ~= chestName then
			if not fillerFound and item["name"] == fillerBlock then 
				fillerFound = true;
			else
				turtle.dropUp(selected)
			end		
		end
	end
	
	turtle.select(1)
	turtle.digUp()
	
end

function placeCeiling()
	if not turtle.detectUp() then 
		util.placeBlockUp(fillerBlock)
	end
end


function placeFloor() 
	if not turtle.detectDown() then 
		util.placeBlockDown(fillerBlock)
	end
end

for d = 1,distance,2 do

	placeFloor()

	for h = 1, height,1 do
		util.detectDigUp()
		turtle.up()
	end
   
	placeCeiling()
	
	util.detectDig()
    turtle.forward()
	
	placeCeiling()
	
	for h = 1, height,1 do
		util.detectDigDown()
		turtle.down()
	end
	
	placeFloor()

	util.detectDig()
    turtle.forward()
	
	if isInventoryFull() then 
		dumpInventory()
	end
	
end

turtle.turnLeft()
turtle.turnLeft()
for d = 1,distance,1 do
	util.detectDig()
	turtle.forward();
end
turtle.turnLeft()
turtle.turnLeft()
dumpInventory()
