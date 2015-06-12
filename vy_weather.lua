require("socket")
http = require("socket.http")
y = {}
u = {}
http.TIMEOUT = 5
retry = true

vel = ""
OnStartup = function()
interval = TmrMan.AddTimer(20*60000,Fetch)
Fetch()
end
ChatArrival = function(user,data)
	local s,e,command = string.find( data, "%b<> %p(%w+)|$")
	if command == "weather" then
		Core.SendToUser(user,"<[DeZire-BOT]> "..vel)
	end
end

OnTimer = function(interval)
Fetch()
end

Fetchtemp  = function()
	
	return tmp
end

Fetch  = function()
	response,err = http.request("http://api.openweathermap.org/data/2.5/weather?id=1259693&mode=json")
	response2,err = http.request("http://api.wunderground.com/api/84672e913672549f/conditions/q/pilani.xml")
	if not (response and response2) then
	if vel == "" and retry then
		retry = false
		Core.SendToAll("Retry")
		Fetch()
	end	
		return true
	end
	local e,s,temp2 = string.find(response2,"<temp_c>(.*)</temp_c>")
	if response ~=nil then
		for  i ,v in response:gmatch'"(%a+)":(%d+[^},]?%d*)' do
			u[i] = v
		end	
	end
	tempp = u['temp'] - 273.15	

	vel = "\nPlace : Pilani\nTemperature (Openweathermap) = "..tempp.."°C\nTemperature (WUnderground) = "..temp2.."°C\nPressure = "..u['pressure'].." hPa\nSunrise = "..os.date("%H:%M:%S",tonumber(u['sunrise'])).."\nSunset = "..os.date("%H:%M:%S",tonumber(u['sunset']))
	retry = true
end