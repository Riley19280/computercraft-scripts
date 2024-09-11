-- https://chart-studio.plotly.com/create/?fid=plotly2_demo:437#/
-- https://github.com/Xytabich/VSMG/blob/master/SphereGenerator/HollowSphere.cs

local spherePoints = {}

print('Radius: ')
local radius = tonumber(io.read())

print('Dome? [y/n]')
local domeInput = io.read()
local isDome = false

if domeInput == 'y' then
    isDome = true
end

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
if io.read() ~= 'y' then
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

for l, levels in ipairs(pointsByY) do
  -- Opens a file in append mode
  print("Writing " .. l)
file = io.open("bigsphere/bigsphere_" ..l .. ".txt", "w")

-- sets the default output file as test.lua
io.output(file)

for i=1, #levels do 
    io.write(levels[i][1] .. ' ' .. levels[i][2] .. " " .. levels[i][3] .. "\n")
end

-- closes the open file
io.close(file)

end
