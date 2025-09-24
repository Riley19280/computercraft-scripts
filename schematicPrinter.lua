require('turtleUtil')
lcs = require('local_coordinate_system')
util = require('util')
buildLib = require('buildLib')

lcs.loadNative()
lcs.forceMoves = true

local removeFileContentsOnLayerCompletion = true

local args = {...}

print("Enter folder path for schematic layers:")
local schematicPath = read()


local progressPath = schematicPath .. '/progress'

function getLayerFiles() 
    local layers = {}
    for _, file in ipairs(fs.list(schematicPath)) do
        if string.sub(file, 1, 6) == "layer_" then
            table.insert(layers, file)
        end
    end

    table.sort(layers, function (a,b) return layerNumberFromFilename(a) < layerNumberFromFilename(b) end)

    return layers
end

function layerNumberFromFilename(filename) 
    local layerNumber = filename:match("^layer_(%d+)%.txt$")
    if layerNumber then
        return tonumber(layerNumber)
    else
        return nil 
    end
end

function shouldStop()
    return fs.exists(progressPath .. '/stop.txt')
end

function doLayer(layerFileName)
    local layerNumber = layerNumberFromFilename(layerFileName)
    print("Starting layer " .. layerNumber)

    configureBuildingForLayer(layerFileName)

    lcs.moveToY(layerNumber + 1)

    local layerCoords = loadLayerProgress(layerFileName)

    print('Blocks to place: ' .. #layerCoords)

    local currentPoint = table.remove(layerCoords, 1)

    while currentPoint ~= nil do
        lcs.moveTo(currentPoint.x , currentPoint.y + 1, currentPoint.z)

        placeBlock()

        logLayerProgress(layerFileName, string.format("%d %d %d", currentPoint.x, currentPoint.y, currentPoint.z))

        table.sort(
            layerCoords, 
            function (a, b)
                return util.manhattanDistance(a.x, a.z, lcs.position.x, lcs.position.z) < util.manhattanDistance(b.x, b.z, lcs.position.x, lcs.position.z)
            end
        )

        currentPoint = table.remove(layerCoords, 1)
    end

    print("Finished layer " .. layerNumber)
end

function loadLayerFile(filePath)
    local coords = {}

    for line in io.lines(filePath) do
        for x, y, z, b in line:gmatch("([+-]?%d+) ([+-]?%d+) ([+-]?%d+)%s*(%S*)") do
            local point = {
                x = tonumber(x),
                y = tonumber(y),
                z = tonumber(z),
                block = b
            }
            
            table.insert(coords, point)
        end
    end

    return coords
end

function getCoordsNotInProgress(layerCoords, progressCoords)
    local progressSet = {}
    for _, progress in ipairs(progressCoords) do
        local key = string.format("%d,%d,%d", progress.x, progress.y, progress.z)
        progressSet[key] = true
    end

    local result = {}
    for _, layer in ipairs(layerCoords) do
        local key = string.format("%d,%d,%d", layer.x, layer.y, layer.z)
        if not progressSet[key] then
            table.insert(result, layer)
        end
    end

    return result
end

function loadLayerProgress(layerFileName)
    local layerCoords = loadLayerFile(schematicPath .. '/' .. layerFileName)


    if fs.exists(progressPath .. '/' .. layerFileName) then
        local progressCoords = loadLayerFile(progressPath .. '/' .. layerFileName)

        return getCoordsNotInProgress(layerCoords, progressCoords)
    end

    return layerCoords
end

function logLayerProgress(layerFileName, text)
    file = io.open(progressPath .. '/' .. layerFileName, "a")
    io.output(file)

    io.write(text .. "\n")
    
    file:close()
end

function placeBlock()
    local block = buildLib.getSelection()

    turtle.select(block)
    turtle.placeDown()
end

function process()
    for _, layerFileName in ipairs(getLayerFiles()) do
        doLayer(layerFileName)

        if removeFileContentsOnLayerCompletion then
            local file = io.open(progressPath .. '/' .. layerFileName, "w")
            io.output(file)
            io.write('')
            file:close()

            file = io.open(schematicPath .. '/' .. layerFileName, "w")
            io.output(file)
            io.write('')
            file:close()
        end
    
        if shouldStop() then
            print("Stop Detected, Exiting")
            lcs.returnOrigin()
            return
        end
    end

    print('Finished!')
    lcs.returnOrigin()
end

function configureBuildingForLayer(layerFileName)
    local totalLayers = #getLayerFiles()
    local layerNumber = layerNumberFromFilename(layerFileName)

    totalLayers = 150

    local deepslate = {
        {value=1,data="minecraft:chiseled_deepslate"},
        {value=2,data="minecraft:polished_deepslate"},
        {value=2,data="minecraft:deepslate_bricks"},
        {value=2,data="minecraft:cracked_deepslate_bricks"},
        {value=2,data="minecraft:deepslate_tiles"},
        {value=2,data="minecraft:cracked_deepslate_tiles"},  
    }

    local quartz = {
        {value=2,data="minecraft:quartz_bricks"},
        {value=2,data="minecraft:quartz_block"},
        {value=2,data="minecraft:smooth_quartz"},
        {value=1,data="minecraft:chiseled_quartz_block"},
    }

    buildLib.refueling = true
    buildLib.chestRefill = true
    buildLib.refillMode = 'remote'
    buildLib.selectionMode = 'blend'

    buildLib.setInventoryBlocks({
        ['minecraft:quartz_block']=1*64,
        ['minecraft:smooth_quartz']=1*64,
        ['minecraft:quartz_bricks']=1*64,
        ['minecraft:chiseled_quartz_block']=1*64,
        ['minecraft:chiseled_deepslate']=1*64,
        ['minecraft:polished_deepslate']=1*64,
        ['minecraft:deepslate_bricks']=1*64,
        ['minecraft:cracked_deepslate_bricks']=1*64,
        ['minecraft:deepslate_tiles']=1*64,
        ['minecraft:cracked_deepslate_tiles']=1*64,
    })

    if layerNumber <= 36 then
        buildLib.distribution = {
            {
                value=1, 
                data=deepslate,
            },
        }
    elseif layerNumber <= totalLayers - 22 then
        buildLib.distribution = {
            {
                value=totalLayers - layerNumber - 22, 
                data=deepslate,
            },
            {
                value=layerNumber - 36, 
                data=quartz,
            }
        }

    else
        buildLib.distribution = {
            {
                value=1, 
                data=quartz,
            },
        }
    end

    buildLib.refillIfNeeded()
end

process()

-- refulel is 80 per coal 5120 per stack