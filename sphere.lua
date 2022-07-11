-- https://chart-studio.plotly.com/create/?fid=plotly2_demo:437#/
-- https://github.com/Xytabich/VSMG/blob/master/SphereGenerator/HollowSphere.cs

require('turtleUtil')
lcs = require('local_coordinate_system')
util = require('util')
buildLib = require('buildLib')

local spherePoints = {}

print('Radius: ')
local radius = tonumber(read())

print('Dome? [y/n]')
local domeInput = read()
local isDome = false

if domeInput == 'y' then
    isDome = true
end

buildLib.interactiveOptions()

function GenerateVoxels(radius)

    local innerRadius = radius - 1
    local even = radius % 2 == 0


    if even then
        FillVoxels(radius - 1, radius * radius - 1, innerRadius * innerRadius - 1, radius, radius - 1);
    else
        FillVoxels(radius, (radius + 1) * (radius + 1) - 1, (innerRadius + 1) * (innerRadius + 1) - 1, radius, radius);
    end
end


function FillVoxels(size, outerRadius, innerRadius, c1, c2)

    local unique = {}

    for x = 0, size, 1 do
    
        local xm = x * x;
        for y = 0, size, 1 do
        
            local ym = y * y;
            for z = 0, size, 1 do
            
                local r = xm + ym + z * z;
                if(r <= outerRadius and r > innerRadius) then 

                        local tables = {
                            {x + c1, y + c1, z + c1},
                            {x + c1, c2 - y, z + c1},
                            {c2 - x, y + c1, z + c1},
                            {c2 - x, c2 - y, z + c1},
                            {x + c1, y + c1, c2 - z},
                            {x + c1, c2 - y, c2 - z},
                            {c2 - x, y + c1, c2 - z},
                            {c2 - x, c2 - y, c2 - z}
                        }

                        for _, v  in ipairs(tables) do
                            -- account for lua starting at 1 since we are about to categorize by y level, and ipairs will not iterate at 0
                            v[2] = v[2] + 1

                            -- shift by radius
                            v[1] = v[1] - radius
                            v[3] = v[3] - radius

                            local ukey = v[1] .. ', ' .. v[2] .. ', ' .. v[3]
                            if not unique[ukey] then
                               table.insert(spherePoints, 1, v)
                               unique[ukey] = true
                            end
                        end
                        
                end
            end
        end
    end
end

-- not sure why this doesnt work
-- function closestBlock(a, b)
--     return util.manhattanDistance3D(a[1], a[2], a[3], lcs.position.x, lcs.position.y, lcs.position.z) < util.manhattanDistance(b[1], b[2],  b[3], lcs.position.x,  lcs.position.y, lcs.position.z)
-- end

function closestBlock(a, b)
    return util.manhattanDistance(a[1], a[3], lcs.position.x, lcs.position.z) < util.manhattanDistance(b[1], b[3], lcs.position.x, lcs.position.z)
end

function findBlockToPlace()
    local block = buildLib.getSelection()
    turtle.select(block)
end

GenerateVoxels(radius)

if isDome then
    local domeCoords = {}

    for k, v in ipairs(spherePoints) do        
        if v[2] >= radius then
            v[2] = v[2] - radius
            table.insert(domeCoords, v)
        end
    end

    spherePoints = domeCoords
end


print("Requires " .. #spherePoints .. ' Blocks. (' .. #spherePoints / 64 .. ' stacks)')
print('Continue? [y/n]')
if read() ~= 'y' then
    return
 end


local pointsByY = {}

for k, v in ipairs(spherePoints) do
    if pointsByY[v[2]] == nil then
        pointsByY[v[2]] = {v}
    else
        table.insert(pointsByY[v[2]], v)
    end
end

for k, v in ipairs(pointsByY) do
    table.sort(pointsByY[k], closestBlock)
end


for l, levels in ipairs(pointsByY) do
    table.sort(levels, closestBlock)
    local currentPoint = table.remove(levels, 1)

    while currentPoint ~= nil do
        -- do not move up by 1 since we accounted for it above
        lcs.moveTo(currentPoint[1] , currentPoint[2], currentPoint[3])
     
        findBlockToPlace()
        turtle.placeDown()

        -- io.write(currentPoint[1] .. ', ' .. currentPoint[2] .. ', ' .. currentPoint[3] .. '\n')

        table.sort(levels, closestBlock)
        currentPoint = table.remove(levels, 1)
    end

end




lcs.returnOrigin('xzy')