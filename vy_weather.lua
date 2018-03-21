require("socket")
http = require("socket.http")
JSON = require("JSON")
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

Fetch = function()
    local response, err = http.request("https://openweathermap.org/data/2.5/weather?appid=b6907d289e10d714a6e88b30761fae22&q=pilani")
    local response2, err = http.request("http://api.wunderground.com/api/84672e913672549f/conditions/q/pilani.json")
    local openWeather = JSON:decode(response)
    local wunderGroundWeather = JSON:decode(response2)['current_observation']

    if not (openWeather and wunderGroundWeather) then
        if vel == "" and retry then
            retry = false
            Fetch()
        end
        return true
    end
    local openTemp = openWeather['main']['temp']
    local wunderTemp = wunderGroundWeather['temp_c']

    vel = "\nPlace : Pilani\nTemperature (Openweathermap) = " .. openTemp ..
            "°C\nTemperature (WUnderground) = " .. wunderTemp ..
            "°C\nPressure = " .. openWeather['main']['pressure'] .. " hPa\nSunrise = " .. os.date("%H:%M:%S", tonumber(openWeather['sys']['sunrise'])) ..
            "\nSunset = " .. os.date("%H:%M:%S", tonumber(openWeather['sys']['sunset']))
    retry = true
end