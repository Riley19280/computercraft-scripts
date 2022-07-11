util = require('util')
buildLib = require('buildLib')


-- -- buildLib.interactiveOptions()

-- buildLib.addInventoryBlock('minecraft:smooth_quartz', 4)
-- buildLib.addInventoryBlock('minecraft:chiseled_quartz_block', 2)
-- buildLib.addInventoryBlock('minecraft:quartz_bricks', 2)
-- buildLib.addInventoryBlock('minecraft:smooth_quartz_stairs', 1)
-- buildLib.addInventoryBlock('minecraft:quartz_pillar', 1)

-- table.insert(turtle.findBlacklist, buildLib.chestName)
-- table.insert(turtle.findBlacklist, buildLib.tempChestName)

-- print(buildLib.getSelection())

print(util.manhattanDistance(1,2,1,3))
print(util.manhattanDistance3D(1,2,1,1,3,1))