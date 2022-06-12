
livingrock = "Botania:livingrock"

function hasItems()
  local sum = 0
  for i = 1,16 do
    sum = sum + turtle.getItemCount(i)
  end
  return sum ~= 0
end

function fillInv()
  for i = 1,16 do
    turtle.select(i)
    turtle.suckDown()
  end
end

function dropItems()
  for i = 1,16 do
    turtle.select(i)
    local data = turtle.getItemDetail()
	if data then
	  if data.name ~= livingrock then 
		turtle.dropDown()
	  end
	end
  end

end

function dropLivingrock()
  for i = 1,16 do
    turtle.select(i)
	local data = turtle.getItemDetail()
	if data then
	  if data.name == livingrock then 
		turtle.dropDown()
		break
	  end
	end
  end
end

function pulse(side, t)
t = t or .1
redstone.setAnalogOutput(side, 15)
sleep(t)
redstone.setAnalogOutput(side, 0)
end

while(true) do

	while (redstone.getInput("front") == false) do
		sleep(3)
	end
	
	pulse("back")
	
	turtle.up()
	turtle.forward()
	turtle.forward()
	fillInv()
	turtle.forward()
	turtle.forward()
	turtle.up()

	dropItems()

	while (redstone.getInput("right") == false) do

	sleep(.5)
	end

	dropLivingrock()
	sleep(2)
	pulse("front", 2)

	turtle.turnLeft()
	turtle.turnLeft()
	turtle.forward()
	turtle.forward()
	turtle.forward()
	turtle.forward()
	turtle.down()
	turtle.down()
	turtle.turnLeft()
	turtle.turnLeft()
	pulse("back")

end
