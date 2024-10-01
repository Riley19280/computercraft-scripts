util = require('util')
require('turtleUtil')

local buildLib = {}

-- can be any, specific, blend, blend-group
buildLib.selectionMode = "any"
buildLib.specificBlock = nil
buildLib.distribution = nil

buildLib.chestRefill = true
buildLib.refillMode = 'remote'
buildLib.chestName = "enderstorage:ender_chest"
buildLib.tempChestName = "minecraft:chest"

buildLib.blacklist = {buildLib.chestName, buildLib.tempChestName}
buildLib.inventoryBlocks = {}


function buildLib.setBlacklist(table)
    buildLib.blacklist = util.clone_table(table)
end

function buildLib.blacklistBlock(block)
    table.insert(buildLib.blacklist, block)
end

function buildLib.setInventoryBlocks(table)
    buildLib.inventoryBlocks = util.clone_table(table)
end

function buildLib.addInventoryBlock(block, count)
    if buildLib.inventoryBlocks[block] == nil then
        buildLib.inventoryBlocks[block] = count
    else
        buildLib.inventoryBlocks[block] = buildLib.inventoryBlocks[block] + count
    end
end

function interactiveInventoryConfig()
    print('Enter inventory manually or read from inventory? [manual, auto]')
    local inventoryConfig = read()
        
    if inventoryConfig ~= 'manual' and inventoryConfig ~= 'auto' then
        print('Invalid mode')
        interactiveInventoryConfig()
    end

   if inventoryConfig == 'manual' then
        interactiveManualInventoryBlockConfig()
    elseif inventoryConfig == 'auto' then
        autoInventoryBlockConfig()
   end

end

function interactiveManualInventoryBlockConfig() 
    print('What block would you like to use?')
    local blockName = read()

    print('How many?')
    local blockCount = read()

    buildLib.addInventoryBlock(blockName, blockCount)

    print('Add another? [y/n]')
    local shouldContinue = read()
        
    if shouldContinue ~= 'y' then
        return
    end

    interactiveManualInventoryBlockConfig() 
end

function autoInventoryBlockConfig()
	for i = 1, 16 do 
		local item = turtle.getItemDetail(i)
        if item and not util.table_has_value(turtle.findBlacklist, item["name"]) then     
            buildLib.addInventoryBlock(item['name'], item['count'])
		end
    end
end

function interactiveChestRefill() 
    print('Refill inventory from chest? [y/n]')
    local chestRefill = read()
        
    if chestRefill == 'y' then
        buildLib.chestRefill = true

        print('Refill mode: [remote, local]')
        buildLib.refillMode = read()

        print('Chest name is '.. buildLib.chestName .. ' would you like to change it? [y/n]')
        local changeChestName = read()
        
        if changeChestName == 'y' then
            print('Enter chest name:')
            buildLib.chestName = read()   
        end

        buildLib.blacklistBlock(buildLib.chestName)
    else
        buildLib.chestRefill = false
        buildLib.chestName = nil
    end
end

function interactiveDistributionInput()
    local distributions = {}
    ::interactiveDistInput::

    print('What block would you like to use?')
    local block = read()

    print('What are the odds of this block being selected? (# out of total)')
    local value = read()
    table.insert(distributions, {data=block, value=value})

    print('Add another distribution? [y/n]')         
    if read() == 'y' then
        goto interactiveDistInput
    end

    return distributions
end

function interactiveSelectionModeInput()
    print('Selection mode: [any, specific, blend, blend-group]')
    buildLib.selectionMode = read()

    if buildLib.selectionMode ~= 'any' and buildLib.selectionMode ~= 'specific' and buildLib.selectionMode ~= 'blend' and buildLib.selectionMode ~= 'blend-group' then
        print('Invalid selection mode')
        interactiveSelectionModeInput()
    end

    if buildLib.selectionMode == 'specific' then
        print('What block would you like to use?')
        buildLib.specificBlock = read()
        print('How many to keep in inventory?')
        local count = tonumber(read())
        buildLib.addInventoryBlock(buildLib.specificBlock, count)
    end

    if buildLib.selectionMode == 'blend' then
        buildLib.distribution = interactiveDistributionInput()
    end

    if buildLib.selectionMode == 'blend-group' then
        buildLib.distribution = {}
        ::blendGroupSelectionMode::

        print('What are the odds of this group being selected? (# out of total)')
        local value = read()
        
        table.insert(buildLib.distribution, {
            value=value,
            data=interactiveDistributionInput(),
        })

        print('Add another group? [y/n]')
        if read() == 'y' then
            goto blendGroupSelectionMode
        end
    end

end

function buildLib.interactiveOptions(optinal)

    if optional then
        print('Would you like to configure block placement options? [y/n]')
        local shouldConfigure = read()
        
        if shouldConfigure ~= 'y' then
            return
        end
    end

    interactiveChestRefill()

    interactiveSelectionModeInput()
    
    interactiveInventoryConfig()

end

function buildLib.syncInventory()
    -- function assumes that there is a chest at the top and bottom
    -- needed block will be taken from the bottom chest and placed into the top one
    
    local blockChest = peripheral.wrap("bottom")
    local tempChest = peripheral.wrap("top")

    local neededItems = buildLib.getMissingInventory()

    for block, neededCount in pairs(neededItems) do
        while neededCount > 0 do
            local pullCount = math.min(neededCount, 64)  -- Pull up to 64 items at a time

            local foundInChest = false
            for i = 1, blockChest.size() do 
                local item = blockChest.getItemDetail(i)
                if item and item['name'] == block then
                    pullCount = math.min(pullCount, item['count'])
                    blockChest.pushItems(peripheral.getName(tempChest), i, pullCount)
                    neededCount = neededCount - pullCount
                    foundInChest = true
                    break
                end
            end

            if not foundInChest then
                pullCount = 0
                print("Not enough " .. block .. " in the chest. Missing " .. neededCount - pullCount .. ". Waiting..")
                sleep(1) 
            end
        end
    end

end

function buildLib.refillInventory(block, count)

    if buildLib.refillMode == 'remote' then
        turtle.detectDigUp()
        turtle.up()
        turtle.detectDigUp()
    
        -- place chest containing block supply
        local blockChest = turtle.awaitItem(buildLib.chestName)
        turtle.select(blockChest)
        turtle.placeDown()

        local tempChest = turtle.awaitItem(buildLib.tempChestName)
        turtle.select(tempChest)
        turtle.placeUp()

        sleep(0.25)

        buildLib.syncInventory()
        
        turtle.digUp()
        turtle.digDown()
        turtle.down()
    end

    if buildLib.refillMode == 'local' then 
        local currentPosition = util.clone_table(lcs.position)

        lcs.returnOrigin()

        turtle.up()
        turtle.forward()

        local tempChest = turtle.awaitItem(buildLib.tempChestName)
        turtle.select(tempChest)
        turtle.placeUp()

        sleep(0.25)

        buildLib.syncInventory()

        turtle.digUp()

        lcs.returnOrigin()

        lcs.moveToPosition(currentPosition)
    end
   
end

function buildLib.refillIfNeeded()
    if not buildLib.chestRefill then
        return
    end

    if not buildLib.inventoryRefillNeeded() then
        return
    end
    
    buildLib.refillInventory()
end

function buildLib.getMissingInventory() 
    local counts = util.clone_table(buildLib.inventoryBlocks)

    for i = 1, 16 do 
		local item = turtle.getItemDetail(i)
        if item and counts[item['name']] ~= nil then     
            counts[item['name']] = counts[item['name']] - item['count']

            if counts[item['name']] <= 0 then
                counts[item['name']] = nil
            end
		end
    end

    return counts
end

function buildLib.inventoryRefillNeeded()
    local neededItems = buildLib.getMissingInventory()

    for block, count in pairs(buildLib.inventoryBlocks) do
        if neededItems[block] ~= nil then
            if count - neededItems[block] == 0 then
                return true
            end
        end
    end

    return false
end

function buildLib.getSelection()
    buildLib.refillIfNeeded()

    local blockIndex = nil
    local blockToFind = nil
    if buildLib.selectionMode == 'any' then 
        blockIndex = turtle.findAnyItem()
    elseif buildLib.selectionMode == 'specific' then 
        blockToFind = buildLib.specificBlock
    elseif buildLib.selectionMode == 'blend' or buildLib.selectionMode == 'blend-group' then 
        blockToFind = util.getDistributionResult(buildLib.distribution)
    end

    if blockIndex then
        return blockIndex
    end

    if blockToFind then
        blockIndex = turtle.findItem(blockToFind)

        if not blockIndex then
            print('Unable to find '..blockToFind..' to place. Waiting..')
            sleep(5)
            return buildLib.getSelection()
        end

        return blockIndex
    end

    return buildLib.getSelection()
end


return buildLib