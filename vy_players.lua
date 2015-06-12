
path =  Core.GetPtokaXPath().."scripts/".."Players.txt"
ChatArrival = function(user,data)
	local s,e,command,arg = string.find( data, "%b<> %p(%w+) (.+)|$")
	if command=="player" then
		resp = ""
		file = io.open(path,"r")
		test = file:read("*all")
		test = test.."\n\n"
		--Core.SendToAll(test)
		local e,s,msg = string.find(test,arg.."(.-)\n\n")
		if msg then
		Core.SendToUser(user,"\n"..arg..msg)
		else
		Core.SendToUser(user,"Player data not available")		
		end
		return true

	end	
end