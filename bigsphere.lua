require('turtleUtil')
lcs = require('local_coordinate_system')
util = require('util')
buildLib = require('buildLib')

lcs.loadNative()

lcs.forceMoves = true

local glass ="minecraft:glass"
buildLib.selectionMode = "specific" 
buildLib.specificBlock = glass
buildLib.addInventoryBlock(glass, 4*64)


local args = {...}

local layer = 0

if not args[1] then
    print('layer number: ')
    layer = tonumber(read())
else 
    layer = args[1]
end

function writeProgress(text)
    file = io.open("progress/bigsphere_" .. layer .. ".txt", "a")

    io.output(file)
    
    io.write(text .. "\n")
    
    io.close(file)
end

local filename = 'bigsphere/bigsphere_' .. layer .. '.txt'

 if not fs.exists(filename) then
    print('Layer not found. Quitting.')
    return 
 end


 
util.chatMessage('Layer ' .. layer .. ' Starting')
writeProgress('Started')
writeProgress(os.clock())

function parseFileToTable(filename)
    local layerCoords = {}

    local file = io.open(filename, "rb") 

    for line in io.lines(filename) do
        local points = {}
        for coord in line:gmatch("%S+") do 
            table.insert(points, tonumber(coord)) 
        end    
      table.insert(layerCoords, points)
    end
    
    file:close()

    return layerCoords
end

function closestBlock(a, b)
    return util.manhattanDistance(a[1], a[3], lcs.position.x, lcs.position.z) < util.manhattanDistance(b[1], b[3], lcs.position.x, lcs.position.z)
end

function findBlockToPlace()
    local block = buildLib.getSelection()
    turtle.select(block)
end

local layerCoords = parseFileToTable(filename)


turtle.up()
turtle.turnRight()
for i = 1, 15 do
    turtle.forward()
end
for i = 1, 5 do
    turtle.up()
end
util.tprint(lcs.position)

print("starting layer schematic")

local startTotal = #layerCoords

table.sort(layerCoords, closestBlock)

local currentPoint = table.remove(layerCoords, 1)

while currentPoint ~= nil do
    lcs.moveTo(currentPoint[1] , currentPoint[2], currentPoint[3])
    
    findBlockToPlace()
    turtle.placeDown()

    table.sort(layerCoords, closestBlock)
    currentPoint = table.remove(layerCoords, 1)


    if turtle.isInventoryFull() then
        turtle.select(turtle.findItem(buildLib.chestName))
        turtle.detectDigUp()
        turtle.placeUp()

        for i = 1, 16 do
            if turtle.getItemDetail(i) then
                if turtle.getItemDetail(i).name ~= glass and turtle.getItemDetail(i).name ~= buildLib.chestName and turtle.getItemDetail(i).name ~= buildLib.tempChestName then
                    turtle.select(i)
                    turtle.dropUp()
                end
            end
        end

        turtle.digUp()
    end

    if math.floor(startTotal / 8) == startTotal - #layerCoords  then
        writeProgress('15 %')
        writeProgress(os.clock())
        util.chatMessage('Layer ' .. layer .. ' 15% finished')
    end

end
writeProgress('Finished')
writeProgress(os.clock())
util.chatMessage('Layer ' .. layer .. ' Finished')
lcs.returnOrigin('yxz')


if args[1] and not fs.exists('progress/stop.txt') then
    shell.run('bigsphere', layer + 1)
end