
require('turtleUtil')

local function moveForward()
    turtle.detectDig()
    turtle.forward()
end

local function moveLeft()
    turtle.turnLeft()
end

local function moveRight()
    turtle.turnRight()
end

local function moveUp()
    turtle.detectDigUp()
    turtle.up()
end

local function moveDown()
    turtle.detectDigDown()
    turtle.down()
end

print("Turtle Controller Started")
print("WASD / Arrows = Move")
print("E or Space = Up | LeftCtrl or Q = Down")

-- Keymap
local keyMap = {
    [keys.w] = moveForward,
    [keys.up] = moveForward,

    [keys.s] = turtle.back,
    [keys.down] = turtle.back,

    [keys.a] = moveLeft,
    [keys.left] = moveLeft,

    [keys.d] = moveRight,
    [keys.right] = moveRight,

    [keys.e] = moveUp,
    [keys.space] = moveUp,
    
    [keys.q] = moveDown,
    [keys.leftCtrl] = moveDown,
}

-- Queue for key events
local queue = {}

-- Collector thread: puts keypresses into the queue
local function collectKeys()
    while true do
        local event, key, held = os.pullEvent("key")
        table.insert(queue, {key=key, held=held})
    end
end

-- Worker thread: pulls keypresses from queue and runs actions
local function processKeys()
    while true do
        if #queue > 0 then
            local evt = table.remove(queue, 1)
            local action = keyMap[evt.key]
            if action then action() end
        else
            sleep(0) -- yield so collectKeys can run
        end
    end
end

-- Run both threads
parallel.waitForAll(collectKeys, processKeys)
