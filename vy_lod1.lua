path = Core.GetPtokaXPath().."scripts/"
require("socket")
http = require("socket.http")
http.TIMEOUT = 5
filename = "arbits.txt"
file = path..filename	
BOT = SetMan.GetString(21)
nicks = {
["Lod1"] = 1,
["TwistedSister"] = 1,
["coldturkey"] = 1,
["The_Awenger"] = 1,
["V10let"] = 1,
}
msg = "\n\n***************************************************ARBITS Daily List***************************************************\n\n"
ChatArrival = function(user,data)
local s,e,code,arg1 = string.find( data, "%b<> %p(%S+)%s?(.*)|$")
	if code=="setarbits" then	
		if(not nicks[user.sNick]) then
			Core.SendToUser(user,"Access to command denied.")
			return true
		end
		fp = io.open(file,"w")
		fp:write(arg1:gsub(" ","\n\n"))
		fp:close()
		Core.SendToUser(user,"Arbits command updated")
		return true
	end
	if code == "arbits" then
		fp = io.open(file,"r")
		reply = fp:read("*a")
		Core.SendToUser(user,"<"..BOT..">".." \n"..msg..reply)	
		return true		
	end

end