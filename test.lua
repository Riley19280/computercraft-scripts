util = require('util')
buildLib = require('buildLib')
lcs = require('local_coordinate_system')

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


buildLib.addInventoryBlock("minecraft:quartz_block", 128)
-- buildLib.addInventoryBlock("minecraft:stone_bricks", 1)
-- buildLib.addInventoryBlock("minecraft:polished_blackstone_bricks", 1)
-- util.tprint(buildLib.distribution)

buildLib.refillMode = 'local'
-- util.tprint(buildLib.getNeededInventory())
-- print(buildLib.refillFromChestIfNeeded())

print(lcs.moveToY(1))