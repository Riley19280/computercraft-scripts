util = require('util')
local args = {...}

local width  = args[1]
local height = args[2]

local fillerBlock = "minecraft:netherrack"

function doPlaceUp()
	if not turtle.detectUp() then 
		util.placeBlockUp(fillerBlock)
	end
end

util.detectDig()
turtle.forward()

for x = 1,width, 2 do
	
    for y = 1, height, 1 do
		doPlaceUp()
		util.detectDig()
		if y ~= height then
			turtle.forward()       
		end
    end

	turtle.turnRight()
	util.detectDig()
	turtle.forward()
	turtle.turnRight()
	util.detectDig()
	turtle.forward()
    
    for y = 1, height, 1 do
        doPlaceUp()
		util.detectDig()
		if y ~= height then
			turtle.forward()       
		end
    end
    
	turtle.turnLeft()
	util.detectDig()
	turtle.forward()
	turtle.turnLeft()

end


