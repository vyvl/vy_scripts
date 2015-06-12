breakfast_path ="breakfast.tbl"
lunch_path = "lunch.tbl"
dinner_path = "dinner.tbl"--dinner_path = Core.GetPtokaXPath().."scripts/".."dinner.tbl"
OnStartup = function()

	if loadfile(breakfast_path) then
		dofile(breakfast_path) -- this reads the breakfast table from a file on disk and loads it to memory
		else
		
	--	Core.SendToAll("nopeb")
		breakfast = {}
	end
	if loadfile(dinner_path) then
		dofile(dinner_path) -- this reads the dinner table from a file on disk and loads it to memory
		else
		
--		Core.SendToAll("noped")
		dinner = {}
	end
	if loadfile(lunch_path) then
		dofile(lunch_path) -- this reads the lunch table from a file on disk and loads it to memory
		else
		-- dofile(lunch_path)
--		 Core.SendToAll("nopel")
		lunch = {}
	end
end	

datem = function(darg)

local datex = os.date("2/%d/%Y",darg)
Core.SendToAll(tostring(datex))
local e,s,day = string.find(datex,"2/0(.)/2015")
if day then
--Core.SendToAll("2/"..day.."/2015")
return "2/"..day.."/2015"
end

return os.date("2/%d/%Y",darg)

end

dateMod = function(datex)


return datex
	
end




ChatArrival = function(user,data)
BOT = "<" .. SetMan.GetString(21) .."> "
 local s,e,command,arg = string.find(data,"%b<>%s%p(%w+)|$")
--datex = os.date("Day %d",os.time())

display_date = os.date("%B %d %Y",os.time())
 if command =="breakfast" then
	hour = os.date("%H")
	local datex = datem(os.time())
 hour = tonumber(hour)
 if (hour >=10) then
	datex = datem(os.time()+24*60*60)	
	Core.SendToAll(dateMod(datex))
	display_date = os.date("%B %d %Y",os.time()+24*60*60)
 end
 if breakfast[dateMod(datex)] then
	reply = "Breakfast Menu for ".. display_date.." \n "..breakfast[dateMod(datex)]

	Core.SendToUser(user,BOT..reply)
	return true
	else		
	Core.SendToUser(user,BOT.." Wait for Menu to be updated")	
	return true
 end
 elseif command=="lunch" then
 local datex = datem(os.time())
 	hour = os.date("%H")
 hour = tonumber(hour)
 if (hour >=14) then
	datex = datem(os.time()+24*60*60)
	display_date = os.date("%B %d %Y",os.time()+24*60*60)
 end
  if lunch[dateMod(datex)] then
  	reply = " Lunch Menu for ".. display_date..":\n "..lunch[dateMod(datex)]

	Core.SendToUser(user,BOT..reply)
	return true
	else	
	Core.SendToUser(user,BOT.." Wait for Menu to be updated")	
	return true
 end
 elseif command =="dinner" then
 local datex = datem(os.time())
 	hour = os.date("%H")
 hour = tonumber(hour)
 if (hour >=21) then
	datex = datem(os.time()+24*60*60)
	display_date = os.date("%B %d %Y",os.time()+24*60*60)
 end
 --Core.SendToAll(dateMod(datex))
   if dinner[dateMod(datex)] then
   	reply = " Dinner Menu for ".. display_date..":\n"..dinner[dateMod(datex)]

	Core.SendToUser(user,BOT..reply)
	return true
	else	
	Core.SendToUser(user,BOT.." Wait for Menu to be updated")	
	return true
 end
 end
 end
