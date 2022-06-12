
local turtleCount=17

local sleepDuration = .5

shell.run('cnc', 'turtle.turnLeft()')
sleep(sleepDuration)
for i=1,turtleCount, 1 do
	shell.run('cnc', 'turtle.dig()')
	sleep(sleepDuration)
	shell.run('cnc', 'turtle.forward()')
	sleep(sleepDuration)
end
shell.run('cnc', 'turtle.turnRight()')
