
livingwood = "Botania:livingwood"
livingrock = "Botania:livingrock"

function doactions()
	anythingThere, item = turtle.inspectDown()
	
	if item.name == livingwood or item.name == livingrock then
		turtle.digDown()
	end
	turtle.placeDown()

end


while(true) do

	turtle.turnLeft()
	turtle.turnLeft()
	turtle.select(1)
	
	turtle.suck(64-turtle.getItemCount())
	turtle.turnRight()
	turtle.turnRight()


	turtle.up()
	turtle.forward()
	doactions()
	turtle.turnLeft()
	turtle.forward()
	doactions()
	turtle.turnRight()
	turtle.forward()
	doactions()
	turtle.forward()
	doactions()
	turtle.turnRight()
	turtle.forward()
	doactions()
	turtle.forward()
	doactions()
	turtle.turnRight()
	turtle.forward()
	doactions()
	turtle.forward()
	doactions()
	turtle.turnRight()
	
	turtle.forward()
	turtle.turnLeft()
	turtle.forward()
	turtle.down()
	turtle.turnLeft()
	turtle.turnLeft()

  turtle.turnRight()
  turtle.turnRight()
  turtle.select(2)
  turtle.drop()
  turtle.turnLeft()	
  turtle.turnLeft()	
	sleep(55)
end
