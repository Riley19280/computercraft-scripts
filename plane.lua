util = require('util')

local args = {...}

local arg1 = args[1]


local fillerBlock = "minecraft:netherrack"

function vertical(length, height)
    if not length or not height then
        error("Length and Height not given")
        return
    end
    
    for x = 1, length, 1 do     
        if x % 2 == 1 then
            for y = 1, height, 1 do
                if not turtle.detect() then
                    util.placeBlock(fillerBlock)
                end
                if y ~= tonumber(height) then
                    util.detectDigUp()
                    turtle.up()
                end
            end
        end
        
        if x % 2 == 0 then
            for y = 1, height, 1 do
                if not turtle.detect() then
                    util.placeBlock(fillerBlock)
                end
                if y ~= tonumber(height) then
                    util.detectDigDown()
                    turtle.down()
                end
            end
        end
    
        -- move to the next row or point back home
        if x ~= length then
            turtle.turnRight()
            util.detectDig()
            turtle.forward()
            turtle.turnLeft()
        else
            turtle.turnLeft()
        end
    end
    
    -- go back down if we ended at the top
    if length % 2 == 1 then
        for y = 1, height, 1 do
            turtle.down()
        end
    end
    
    for d = 1, length - 1, 1 do
        util.detectDig()
        turtle.forward();
    end
    turtle.turnRight()
end



function horizontal(width, length, direction)
    if not width or not length then
        error("Width and Length not given")
        return
    end

    for x = 1, width, 1 do
    
        for y = 1, length, 1 do

            if direction == 'up' then
                if not turtle.detectUp() then 
                    util.placeBlockUp(fillerBlock)
                end
            elseif direction == 'down' then
                if not turtle.detectDown() then 
                    util.placeBlockDown(fillerBlock)
                end
            else
                error('Direction ' .. direction .. " is not valid")
            end

            
            util.detectDig()
            if y ~= length then
                turtle.forward()       
            end
        end
        
        if x ~= width then
            if x % 2 == 1 then
                turtle.turnRight()
                util.detectDig()
                turtle.forward()
                turtle.turnRight()
            end
            if x % 2 == 0 then
                turtle.turnLeft()
                util.detectDig()
                turtle.forward()
                turtle.turnLeft()	
            end
        else
            -- go back to the beginning of the column
            if x % 2 == 1 then
                turtle.turnRight()
                turtle.turnRight()
                for d = 1, length - 1, 1 do
                    util.detectDig()
                    turtle.forward();
                end
            end
            if x % 2 == 0 then
            end
        end
            
    end

    turtle.turnRight()
    for d = 1, width - 1, 1 do
        util.detectDig()
        turtle.forward();
    end

    turtle.turnRight()
end


if arg1 == 'wall' or arg1 == 'vertical' then
    fillerBlock = args[4] or fillerBlock
    return vertical(tonumber(args[2]), tonumber(args[3]))
end


if arg1 == 'ceiling' then
    fillerBlock = args[4] or fillerBlock
    return horizontal(tonumber(args[2]), tonumber(args[3]), 'up')
end

if arg1 == 'floor' then
    fillerBlock = args[4] or fillerBlock
    return horizontal(tonumber(args[2]), tonumber(args[3]), 'down')
end

if arg1 == 'horizontal' then
    fillerBlock = args[5] or fillerBlock
    if args[2] == 'up' then
        return horizontal(tonumber(args[3]), tonumber(args[4]), 'up')
    elseif args[2] == 'down' then
        return horizontal(tonumber(args[3]), tonumber(args[4]), 'down')
    else
        error('Argument 2 direction must be up or down')
    end
end