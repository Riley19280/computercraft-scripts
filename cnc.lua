local args = {...}

rednet.open("right")
rednet.broadcast(table.concat(args, " "), "miners")
