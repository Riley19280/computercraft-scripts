testBlock = 'Thaumcraft:blockStoneDevice'
forward = 0

function findSlot()
  for i = 1,16 do
    if turtle.getItemCount(i) ~= 0 then
      return i
    end
  end
  return -1
end

function fillInv()
  for i = 1,16 do
    turtle.select(i)
    turtle.suck()
  end
end

function hasItems()
  local sum = 0
  for i = 1,16 do
    sum = sum + turtle.getItemCount(i)
  end
  return sum ~= 0
end

function routine()

  if not hasItems() then
	print("actually no items")
	return 1
  end

  if redstone.getInput('left') then
    print('redstone detected')
    return
  end

  turtle.turnRight()

  local success, data = turtle.inspect()
  if not success then
    print('failed to inspect after redstone signal')
    turtle.turnLeft()
    return
  end

  if testBlock ~= data.name then
    print('Block is not '..testBlock)
    turtle.turnLeft()
    return
  end



  local slot = findSlot()
  if slot == -1 then
    print('No items found, aborting')
    turtle.turnLeft()
    return 1
  end

  turtle.select(slot)
  turtle.drop()
  turtle.turnLeft()

end

while(true) do

  fillInv() 

  if not hasItems() then
    sleep(3)
  else
	fillInv() 
	--sleep(1)
	--fillInv()

    turtle.turnLeft()
    turtle.turnLeft()
	
    while(not turtle.detect()) do
      local res = routine()
      turtle.forward()
	  if res == 1 then	
		break
	  end
    end

    turtle.turnLeft()
    turtle.turnLeft()

    while(not turtle.detect()) do
      turtle.forward()
    end

  end
end
