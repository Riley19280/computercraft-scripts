util = require('util')
require('turtleUtil')

local buildLib = {}

-- can be random, any, or specific
buildLib.selectionMode = "random" 
buildLib.specificBlock = nil
buildLib.distribution = nil

buildLib.chestRefill = true
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

function buildLib.addInventoryBlock(block, stacks)
    table.insert(buildLib.inventoryBlocks, {name=block, count=stacks})
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
        interactiveAutoInventoryBlockConfig()
   end

end

function interactiveManualInventoryBlockConfig() 
    print('What block would you like to use?')
    local blockName = read()

    print('How many stacks')
    local blockCount = read()

    buildLib.addInventoryBlock(blockName, blockCount)

    print('Add another? [y/n]')
    local shouldContinue = read()
        
    if shouldContinue ~= 'y' then
        return
    end

    interactiveManualInventoryBlockConfig() 
end

function interactiveAutoInventoryBlockConfig() 
    local invHashMap = {}
	for i = 1, 16 do 
		local item = turtle.getItemDetail(i)
        if item and not util.table_has_value(turtle.findBlacklist, item["name"]) then     
            if invHashMap[item['name']] == nil then
                invHashMap[item['name']] = 1
            else
                invHashMap[item['name']] = invHashMap[item['name']] + 1
            end
		end
    end
    
    for k, v in pairs(invHashMap) do
        buildLib.addInventoryBlock(k, v)
    end
end

function interactiveChestRefill() 
    print('Refill inventory from chest? [y/n]')
    local chestRefill = read()
        
    if chestRefill == 'y' then
        buildLib.chestRefill = true

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
    buildLib.addInventoryBlock(block, 1)

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
    print('Selection mode: [random, any, specific, blend, blend-group]')
    buildLib.selectionMode = read()

    if buildLib.selectionMode ~= 'random' and buildLib.selectionMode ~= 'any' and buildLib.selectionMode ~= 'specific' and buildLib.selectionMode ~= 'blend' and buildLib.selectionMode ~= 'blend-group' then
        print('Invalid selection mode')
        interactiveSelectionModeInput()
    end

    if buildLib.selectionMode == 'specific' then
        print('What block would you like to use?')
        buildLib.specificBlock = read()
        buildLib.addInventoryBlock(buildLib.specificBlock, 1)
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

function buildLib.getBlockFromChest(block)
    turtle.detectDigUp()
    turtle.up()
    turtle.detectDigUp()
    sleep(.1)

    -- place chest containing block supply
    local foundChest = turtle.findItem(buildLib.chestName)

    if foundChest == nil then
        turtle.down()
        print("Unable to find chest " .. buildLib.chestName .. '. Waiting for chest.')
        sleep(5)
        return buildLib.getBlockFromChest(block)
    end

    turtle.select(foundChest)
    turtle.placeUp()
    
    -- place temp chest to move blocks into
    local foundChest = turtle.findItem(buildLib.tempChestName)

    if foundChest == nil then
        turtle.detectDigUp()
        turtle.down()
        print("Unable to find chest " .. buildLib.tempChestName .. '. Waiting for chest.')
        sleep(5)
        return buildLib.getBlockFromChest(block)
    end

    turtle.select(foundChest)
    turtle.placeDown()
    
    sleep(.25)

    local perChest = peripheral.wrap("top")
    local tempChest = peripheral.wrap("bottom")
    local found = false
    for i = 1, perChest.size() do 
		local item = perChest.getItemDetail(i)
        if item and item['name'] == block then
            perChest.pushItems(peripheral.getName(tempChest), i)
            found = true
            break
		end
    end

    turtle.digUp()
    turtle.digDown()
    turtle.down()

    if not found then
        print("Unable to find block " .. block .. '. Waiting for blocks..')
        sleep(5)
        return buildLib.getBlockFromChest(block)
    end

end

function getAnyBlockFromChest() 
    turtle.detectDigUp()
    -- place chest containing block supply
    local foundChest = turtle.findItem(buildLib.chestName)

    if foundChest == nil then
        print("Unable to find chest " .. buildLib.chestName .. '. Waiting for chest.')
        sleep(5)
        return getAnyBlockFromChest()
    end

    turtle.suckUp()
    turtle.digUp()

    turtle.findAnyItem()
end

function buildLib.refillFromChestIfNeeded()
    if buildLib.chestRefill == false then
        return
    end

    if #buildLib.inventoryBlocks == 0 then
        if not turtle.findAnyItem() then
            getAnyBlockFromChest()
        end
    else
        if hasCorrectInventory() then
            return
        end
    
        for k, v in pairs(buildLib.getNeededInventory()) do
            for i = 1, v do
                buildLib.getBlockFromChest(k)
            end
        end
    end

end

function buildLib.getNeededInventory() 
    local counts = {}

    for k, v in pairs(buildLib.inventoryBlocks) do
        counts[v['name']] = v['count']
    end

    for i = 1, 16 do 
		local item = turtle.getItemDetail(i)
        if item and counts[item['name']] ~= nil then     
            counts[item['name']] = counts[item['name']] - 1
		end
    end

    return counts
end

function hasCorrectInventory()
    for k, v in pairs(buildLib.getNeededInventory()) do
        if v ~= 0 then
            return false
        end
    end

    return true
end

function buildLib.getBlendSelection(distribution)
    local result = util.getDistributionResult(distribution)

    if result == nil then return result end

    return turtle.findItem(result)
end

function buildLib.getSelection()
    buildLib.refillFromChestIfNeeded()

    local blockIndex = nil
    if buildLib.selectionMode == 'random' then 
        blockIndex = turtle.findRandomItem()
    elseif buildLib.selectionMode == 'any' then 
        blockIndex = turtle.findAnyItem()
    elseif buildLib.selectionMode == 'specific' then 
        blockIndex = turtle.findItem(buildLib.specificBlock)
    elseif buildLib.selectionMode == 'blend' or buildLib.selectionMode == 'blend-group' then 
        blockIndex = util.getDistributionResult(buildLib.distribution)
    end

    if blockIndex then
        return blockIndex
    end

    print('Unable to find a block to place. Waiting..')
    sleep(5)
    return buildLib.getSelection()
end


return buildLib