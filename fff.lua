util = require('util')
lcs = require('local_coordinate_system')

lcs.loadNative()

print('0,0 1,1', util.manhattanDistance(0,0,1,1))
print('0,0 -1,-1', util.manhattanDistance(0,0,-1,-1))
print('-1,-1 1,1', util.manhattanDistance(-1,-1,1,1))

-- lcs.moveToPosition({x = 1, y = 0, z = 0})
-- util.tprint(lcs.position)
-- read()
-- lcs.returnOrigin()


-- lcs.moveToPosition({x = -1, y = 0, z = 0})
-- util.tprint(lcs.position)
-- read()
-- lcs.returnOrigin()

-- lcs.moveToPosition({x = 0, y = 0, z = 1})
-- util.tprint(lcs.position)
-- read()
-- lcs.returnOrigin()

-- lcs.moveToPosition({x = 0, y = 0, z = -1})
-- util.tprint(lcs.position)
-- read()
-- lcs.returnOrigin()

