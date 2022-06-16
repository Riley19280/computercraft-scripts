--https://www.redblobgames.com/grids/circle-drawing/
--https://donatstudios.com/PixelCircleGenerator
--https://github.com/donatj/Circle-Generator/blob/master/generator.js
require('turtleUtil')
lcs = require('local_coordinate_system')
util = require('util')


lcs.loadNative()

local args = {...}

if not args[1] or not args[2] then
    error('X and Y required')
    return
end

local radiusX = tonumber(args[1]) / 2
local radiusY = tonumber(args[2]) / 2

local height = tonumber(args[3]) or 1

local thickness = 'thin'

if tonumber(args[3]) ~= nil then
    height = args[3]
    thickness = args[4] or 'thin'
else
    thickness = args[3] or 'thin'
end

local ratio = radiusX / radiusY;


local maxblocks_x = 0
local maxblocks_y = 0


if (radiusX * 2) % 2 == 0 then
    maxblocks_x = math.ceil(radiusX - .5) * 2 + 1;
 else 
    maxblocks_x = math.ceil(radiusX) * 2;
end

if (radiusY * 2) % 2 == 0 then
    maxblocks_y = math.ceil(radiusY - .5) * 2 + 1;
else 
    maxblocks_y = math.ceil(radiusY) * 2;
end

function distance(x, y, ratio) 
    return ((y * ratio) ^ 2) + (x ^ 2);
end

function filled(x, y, radius, ratio)
    return distance(x, y, ratio) <= radius ^ 2
end

function fatfilled(x, y, radius, ratio)
    return filled(x, y, radius, ratio) and 
    not (
        filled(x + 1, y, radius, ratio) and
        filled(x - 1, y, radius, ratio) and
        filled(x, y + 1, radius, ratio) and
        filled(x, y - 1, radius, ratio) and
        filled(x + 1, y + 1, radius, ratio) and
        filled(x + 1, y - 1, radius, ratio) and
        filled(x - 1, y - 1, radius, ratio) and
        filled(x - 1, y + 1, radius, ratio)
    )
end

local circlePoints = {}

for y = -maxblocks_y / 2 + 1, maxblocks_y / 2 - 1, 1 do
    for x = -maxblocks_x / 2 + 1, maxblocks_x / 2 - 1, 1 do
        local xfilled;

        if thickness == 'thick' then
            xfilled = fatfilled(x, y, radiusX, ratio)
        elseif thickness == 'thin' then
            local dx
            local dy

            if x > 0 then dx = 1 else dx = -1 end
            if y > 0 then dy = 1 else dy = -1 end

            xfilled = fatfilled(x, y, radiusX, ratio) and not (fatfilled(x + dx, y, radiusX, ratio) and fatfilled(x, y + dy, radiusX, ratio));
        elseif thickness == 'filled' then
            xfilled = filled(x, y, radiusX, ratio);
        else
            error('Option' .. thickness .. ' not supported')
            return
        end

        if xfilled then 
            table.insert(circlePoints, {math.floor(x), math.floor(y)})
        end

    end
end
  
function closestBlock(a, b)
    return util.manhattanDistance(a[1], a[2], lcs.position.x, lcs.position.z) < util.manhattanDistance(b[1], b[2], lcs.position.x, lcs.position.z)
end

for h = 0, height - 1, 1 do
    local pointsToVisit = util.clone_table(circlePoints)

    table.sort(pointsToVisit, closestBlock)


    local currentPoint = table.remove(pointsToVisit, 1)
    
    while currentPoint ~= nil do
        lcs.moveTo(currentPoint[1], h + 1, currentPoint[2])
        turtle.placeDown()
    
        table.sort(pointsToVisit, closestBlock)
        currentPoint = table.remove(pointsToVisit, 1)
    end
end

lcs.returnOrigin('xzy')