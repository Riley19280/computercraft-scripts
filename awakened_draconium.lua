
local baseurl = "http://stats.rileystech.com:9090"
local logurl = baseurl.."/log"
local aedataurl = baseurl.."/aeitems"

local recipe = {
	coreName = "DraconicEvolution:draconicCore",
	coreCount = 16,
	heartName = "DraconicEvolution:dragonHeart",
	heartCount = 1,
	tntName = "minecraft:tnt",
	tntCount = 1,
	blockName = "DraconicEvolution:draconium",
	blockCount = 4
}

local awakenedName = "DraconicEvolution:draconicBlock"

function hasItems()
  local sum = 0
  for i = 1,16 do
    sum = sum + turtle.getItemCount(i)
  end
  return sum ~= 0
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function try(f, catch_f)
	local status, exception = pcall(f)
	if not status then
		catch_f(exception)
	end
end

function netlog(text)
  http.post(logurl, text)
end


function pulse(side, t)
t = t or .1
redstone.setAnalogOutput(side, 15)
sleep(t)
redstone.setAnalogOutput(side, 0)
end

function putItemsBack()
	for i = 1,16 do
		turtle.select(i)
		turtle.drop()
	end
end

function retryAndAbortRecipe()
	print("Recipe aborted")
	putItemsBack()
	redstone.setAnalogOutput("right", 0)
	sleep(1)
	getRecipeItems()
end

local coreIndex = 0
local heartIndex = 0
local tntIndex = 0
local blockIndex = 0

function getRecipeItems()
	redstone.setAnalogOutput("right", 15)
	sleep(.2)

	for i = 1,4 do
		turtle.select(i)
		turtle.suck()
		local detail = turtle.getItemDetail()
		if detail ~= None then
			if detail.name == recipe["coreName"] then
				coreIndex = i
				if detail.count ~= recipe["coreCount"] then
					retryAndAbortRecipe()
					break
				end
			elseif detail.name == recipe["heartName"] then
				heartIndex = i
				if detail.count ~= recipe["heartCount"] then
					retryAndAbortRecipe()
					break
				end
			elseif detail.name == recipe["tntName"] then
				tntIndex = i
				if detail.count ~= recipe["tntCount"] then
					retryAndAbortRecipe()
					break
				end
			elseif detail.name == recipe["blockName"] then
				blockIndex = i
				if detail.count ~= recipe["blockCount"] then
					retryAndAbortRecipe()
					break
				end
			end
		end

	end

	redstone.setAnalogOutput("right", 0)
	return true
end


while(true) do
	getRecipeItems()

	if hasItems() then

		turtle.select(tntIndex)
		turtle.placeDown()
		turtle.select(heartIndex)
		turtle.dropDown()
		sleep(4)

		turtle.select(coreIndex)
		turtle.dropDown()

		turtle.select(blockIndex)


		turtle.turnLeft()
		turtle.turnLeft()
		turtle.place()

		turtle.turnRight()
		turtle.forward()
		turtle.turnLeft()
		turtle.place()

		turtle.turnRight()
		turtle.place()

		turtle.down()
		turtle.placeUp()


		print("waiting for convert")

		local done = false

		while done ~= true do
			local success, data = turtle.inspectUp()
			if data["name"] == awakenedName or success == false then
				done = true
			end
			sleep(1)
		end

		while not turtle.detectUp() do
			sleep(1)
		end

		sleep(3)
		turtle.up()

		turtle.turnLeft()
		turtle.turnLeft()
		turtle.forward()
		turtle.turnLeft()



	else
		sleep(3)
	end
end
