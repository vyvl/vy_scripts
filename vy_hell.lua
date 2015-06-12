require("socket")
http = require("socket.http")
http.TIMEOUT = 5
link = "http://www.dictionaryapi.com/api/v1/references/learners/xml/"
key = "?key=1a78d0a1-8b7e-475e-a56e-6e410310bb07"
bot ="[DeZire-BOT]"
ChatArrival = function(user,data)
	local s,e,command,arg = string.find( data, "%b<> %p(%w+) (%S+).*|")	

	if command == "dict" then
		Fetch(user,arg)
		
		return true
	end
	
end
Fetch = function(user,arg)
	arg = string.lower(arg)
	url = link..arg..key
	response,err = http.request(url)
	if not response then
		Core.SendToUser(user,"<"..bot.."> \n".."Word not found")
		 return true
	end
	local e,s,test = string.find(response,"<dt>.-:(.-)<")
	
	if not test then
		Core.SendToUser(user,"<"..bot.."> \n".."Word not found")
		 return true
	end
	test = string.gsub(test,":",",")

	local e,s,example = string.find(response,"<vi>(.-)</vi>")
	if not example then
			meaning = test
			test = arg.." : "..meaning
		Core.SendToUser(user,"<"..bot.."> \n"..test)
		 return true
	end
	example = string.gsub(example,"<it>","")
	if not example then
		Core.SendToUser(user,"<"..bot.."> \n".."Word not found")
		 return true
	end
	example = string.gsub(example,"</it>","")
	meaning = test
	test = arg.." : "..meaning.."\nExample: "..example
	
	
	if not test then
		 Core.SendToUser(user,"<"..bot.."> \n".."Word not found")
		 return true
	end
	Core.SendToUser(user,"<"..bot.."> \n"..test)
	
	
end	