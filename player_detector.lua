util = require('util')

while true do
 
    local detector = peripheral.find("playerDetector")
    local playerList = detector.getPlayersInRange(32)
    local near = false
     
    for i, name in pairs(playerList) do
        near = true
        break
    end
     
    if near
        then
            print("Turning off")
            redstone.setOutput("right", false)
        else
            print("Turning on")
            redstone.setOutput("right", true)
    end
     
    sleep(1)
end