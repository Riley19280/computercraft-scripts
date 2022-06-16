 local lcs = {}

lcs.position  = {x = 0, y = 0, z = 0}
lcs.direction = 0

function lcs.turnLeft()
    if lcs.isNative() then
        turtle.o_turnLeft()
    else
        turtle.turnLeft()
    end
    lcs.direction = lcs.direction - 1
    if lcs.direction < 0 then
        lcs.direction = lcs.direction + 4
    end
end
 
function lcs.turnRight()
    if lcs.isNative() then
        turtle.o_turnRight()
    else
        turtle.turnRight()
    end
    
    lcs.direction = lcs.direction + 1
    if lcs.direction > 3 then
        lcs.direction = lcs.direction - 4
    end
end
 
function lcs.forward()
    local result = false

    if lcs.isNative() then
        result = turtle.o_forward()
    else
        result = turtle.forward()
    end
    
    if result == true then
        if lcs.direction == 0 then
            lcs.position.z = lcs.position.z - 1
        elseif lcs.direction == 1 then
            lcs.position.x = lcs.position.x + 1
        elseif lcs.direction == 2 then
            lcs.position.z = lcs.position.z + 1
        elseif lcs.direction == 3 then
            lcs.position.x = lcs.position.x - 1
        end
        return true
    else
        return false
    end
end

function lcs.up()
    local result = false

    if lcs.isNative() then
        result = turtle.o_up()
    else
        result = turtle.up()
    end

    if result == false then
        return false
    else
        lcs.position.y = lcs.position.y + 1
        return true
    end
end

function lcs.down()
    local result = false

    if lcs.isNative() then
        result = turtle.o_down()
    else
        result = turtle.down()
    end

    if result == false then
        return false
    else
        lcs.position.y = lcs.position.y - 1
        return true
    end
end

function lcs.setDirection(dir)
    local dirVal = 0
    if dir == "forward" then
        dirVal = 0
        elseif dir == "right" then
        dirVal = 1
        elseif dir == "back" then
        dirVal = 2
        elseif dir == "left" then
        dirVal = 3
    end
    if (dirVal + 2) == lcs.direction or (dirVal - 2) == lcs.direction then
        lcs.turnRight()
        lcs.turnRight()
        elseif (lcs.direction + 1) == dirVal or (lcs.direction - 3) == dirVal then
        lcs.turnRight()
        elseif (lcs.direction - 1) == dirVal or (lcs.direction + 3) == dirVal then
        lcs.turnLeft()
    end
end
 
function lcs.forceMove(dir, dist)
    local moveDir = dir
    local moveDist = dist
    if moveDist == nil then
        moveDist = 1
    end
    if moveDir == "up" then
        for i = 1, moveDist do
            while lcs.up() == false do
                turtle.digUp()
            end
        end
    elseif moveDir == "down" then
        for i = 1, moveDist do
            while lcs.down() == false do
                turtle.digDown()
            end
        end
    elseif moveDir == "forward" then
        for i = 1, moveDist do
            while lcs.forward() == false do
                turtle.dig()
            end
        end
    end
end
 
function lcs.returnOrigin(order)
    local res = lcs.moveTo(0, 0, 0, order) 
    lcs.setDirection('forward')
    return res
end

function lcs.moveToPosition(xyz, order)
    if not order then order = 'yxz' end

    order:gsub(".", function(c)
        if c == 'x' then lcs.moveToX(xyz.x) end
        if c == 'y' then lcs.moveToY(xyz.y) end
        if c == 'z' then lcs.moveToZ(xyz.z) end
    end)
end

function lcs.moveTo(x, y, z, order)
    if not order then order = 'xzy' end

    order:gsub(".", function(c)
        if c == 'x' then lcs.moveToX(x) end
        if c == 'y' then lcs.moveToY(y) end
        if c == 'z' then lcs.moveToZ(z) end
    end)
end

function lcs.moveToY(y)
    while (y > lcs.position.y) do
        while lcs.up() == false do
            return false
        end
    end
    while (y < lcs.position.y) do
        while lcs.down() == false do
            return false
        end
    end
end
 
function lcs.moveToX(x)
    if x < lcs.position.x then
        lcs.setDirection("left")
        while x < lcs.position.x do
            while lcs.forward() == false do
                return false
            end
        end
    elseif x > lcs.position.x then
        lcs.setDirection("right")
        while x > lcs.position.x do
            while lcs.forward() == false do
                return false
            end
        end
    end
end
 
function lcs.moveToZ(z)
    if z > lcs.position.z then
        lcs.setDirection("back")
        while z > lcs.position.z do
            while lcs.forward() == false do
                return false
            end
        end
    elseif z < lcs.position.z then
        lcs.setDirection("forward")
        while z < lcs.position.z do
            while lcs.forward() == false do
                return false
            end
        end
    end
end
 
function lcs.returnSavedDir()
    lcs.setDirection(lcs.savedDir)
end

function lcs.isNative() 
    return turtle.forward == lcs.forward
end

function lcs.loadNative()
    -- save native references if they do not already exist
    if not turtle.o_forward then
        turtle.o_forward = turtle.forward
        turtle.o_up = turtle.up
        turtle.o_down = turtle.down

        turtle.o_turnRight = turtle.turnRight
        turtle.o_turnLeft = turtle.turnLeft
    end

    -- load our tracker references
    turtle.forward = lcs.forward
    turtle.up = lcs.up
    turtle.down = lcs.down

    turtle.turnRight = lcs.turnRight
    turtle.turnLeft = lcs.turnLeft
end

function lcs.unloadNative() 
    -- restore our native functions
    
    turtle.forward = turtle.o_forward
    turtle.up = turtle.o_up
    turtle.down = turtle.o_down

    turtle.turnRight = turtle.o_turnRight
    turtle.turnLeft = turtle.o_turnLeft

    -- remove our tracker references
    turtle.o_forward = nil
    turtle.o_up = nil
    turtle.o_down = nil

    turtle.o_turnRight = nil
    turtle.o_turnLeft = nil
end

return lcs