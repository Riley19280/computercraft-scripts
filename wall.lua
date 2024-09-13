require('turtleUtil')
buildLib = require('buildLib')

local args = {...}

local length = args[1]
local height = args[2]

if not args[1] then
    print('Length:')
    length = read()
end

if not args[2] then
    print('Height:')
    height = read()
end

length = tonumber(length)
height = tonumber(height)

-- buildLib.interactiveOptions()

buildLib.selectionMode = 'blend'
buildLib.distribution = {
    {value=3,data={
        {value=3,data="minecraft:stone_bricks"},
        {value=1,data="minecraft:stone"}
    }},
    {value=1,data="minecraft:polished_blackstone_bricks"},
}

print(height)
print(type(height))

function doPlace()
	
	if  turtle.detect() then 
		return
	end

	local selection = buildLib.getSelection()
	local slot = turtle.findItem(selection)

	if slot ~= nil then
		turtle.select(slot)
		turtle.place()
	else
		print('Could not find selection' .. selection)
	end
end

turtle.detectDig()
turtle.forward()

for x = 1, length, 2 do
	turtle.turnLeft()
    for y = 1, height, 1 do
		doPlace()
		if y ~= height then
			turtle.detectDigUp()
			turtle.up()     
		end
    end
	turtle.turnRight()

	turtle.detectDig()
	turtle.forward()
    
	turtle.turnLeft()
    for y = 1, height, 1 do
		doPlace()
		if y ~= height then
			turtle.detectDigDown()
			turtle.down()     
		end
    end
	turtle.turnRight()
    
	turtle.detectDig()
	turtle.forward()
end

turtle.turnLeft()
turtle.turnLeft()
for d = 1,length,1 do
	turtle.detectDig()
	turtle.forward();
end
turtle.turnLeft()
turtle.turnLeft()


