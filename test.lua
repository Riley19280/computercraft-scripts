util = require('util')
buildLib = require('buildLib')
lcs = require('local_coordinate_system')
-- plane = require('plane')
-- -- buildLib.interactiveOptions()

-- buildLib.addInventoryBlock('minecraft:smooth_quartz', 4)
-- buildLib.addInventoryBlock('minecraft:chiseled_quartz_block', 2)
-- buildLib.addInventoryBlock('minecraft:quartz_bricks', 2)
-- buildLib.addInventoryBlock('minecraft:smooth_quartz_stairs', 1)
-- buildLib.addInventoryBlock('minecraft:quartz_pillar', 1)

-- table.insert(turtle.findBlacklist, buildLib.chestName)
-- table.insert(turtle.findBlacklist, buildLib.tempChestName)

-- print(buildLib.getSelection())

-- print(util.manhattanDistance(1,2,1,3))
-- print(util.manhattanDistance3D(1,2,1,1,3,1))

-- buildLib.interactiveOptions()

buildLib.chestRefill = true
buildLib.refillMode = 'remote'
buildLib.selectionMode = 'blend'
buildLib.refueling = true

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

buildLib.refillIfNeeded()