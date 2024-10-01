require('turtleUtil')
buildLib = require('buildLib')

local bonemeal = 'minecraft:bone_meal'
local sapling  = 'minecraft:birch_sapling'
local air = 'minecraft:air'

buildLib.addInventoryBlock(sapling, 64)
buildLib.addInventoryBlock(bonemeal, 64*3)

while true do
    buildLib.refillFromChestIfNeeded()
    
    local success, data = turtle.inspect()

    if not success then
        turtle.select(turtle.findItem(sapling))
        turtle.place()

        success, data = turtle.inspect()
        while data.name == sapling do
            turtle.select(turtle.findItem(bonemeal))
            turtle.place()
            success, data = turtle.inspect()
        end
    end

    local up = 0
    while turtle.inspect() do
        turtle.dig()
        turtle.detectDigUp()
        turtle.up()
        up = up + 1
    end

    for i = 0, up, 1 do
        turtle.down()
    end

    turtle.suckUp()

    if turtle.isInventoryFull() then
        turtle.select(turtle.findItem(buildLib.chestName))
        turtle.placeUp()

        local foundSapling = false

        for i = 1, 16 do
            if turtle.getItemDetail(i) then
                if turtle.getItemDetail(i).name == sapling and foundSapling then
                    turtle.select(i)
                    turtle.dropUp()
                elseif turtle.getItemDetail(i).name == sapling then
                    foundSapling = true
                elseif turtle.getItemDetail(i).name ~= bonemeal and turtle.getItemDetail(i).name ~= buildLib.chestName and turtle.getItemDetail(i).name ~= buildLib.tempChestName then
                    turtle.select(i)
                    turtle.dropUp()
                end
            end
        end

        turtle.digUp()
    end

end