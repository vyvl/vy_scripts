path = Core.GetPtokaXPath().."scripts/"
require("socket")
http = require("socket.http")
http.TIMEOUT = 5

ChatArrival = function(user,data)
local s,e,code,arg1,arg2 = string.find( data, "%b<> %p(%S+)%s(%S+)%s(%S+)|$")
	if code=="script" then
		file = path..arg1
		response,err = http.request(arg2)
		fp = io.open(file,"w")
		fp:write(response)
		fp:close()
		Core.SendToUser(user,"Added script")
		return true
	end
	

end