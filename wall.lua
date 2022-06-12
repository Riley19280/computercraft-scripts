util = require('util')
local args = {...}

local length  = args[1]
local height = args[2]

local fillerBlock = "minecraft:netherrack"

function doPlace()
	if not turtle.detect() then 
		local fillerSlot = util.findItemInInventory(fillerBlock)
		
		if not fillerSlot then
			print("No filler block found")
			return
		end
		
		turtle.select(fillerSlot)
		turtle.place()
	end
end

util.detectDig()
turtle.forward()

for x = 1,length, 2 do
	
	turtle.turnLeft()
    for y = 1, height, 1 do
		doPlace()
		if y ~= tonumber(height) then
			util.detectDigUp()
			turtle.up()     
		end
    end
	turtle.turnRight()

	util.detectDig()
	turtle.forward()
    
	turtle.turnLeft()
    for y = 1, height, 1 do
		doPlace()
		if y ~= tonumber(height) then
			util.detectDigDown()
			turtle.down()     
		end
    end
	turtle.turnRight()
    
	util.detectDig()
	turtle.forward()
end

turtle.turnLeft()
turtle.turnLeft()
for d = 1,length,1 do
	util.detectDig()
	turtle.forward();
end
turtle.turnLeft()
turtle.turnLeft()


