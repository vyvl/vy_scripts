OnStartup = function()
	require("socket")
	http = require("socket.http")
	http.TIMEOUT = 5
end

ChatArrival = function(user,data)
	local s,e,command = string.find( data, "%b<> %p(%w+).*|$")
	if command=="football" then
		Fetch()
	end
	
end

	
Fetch = function()
	url = "http://www.scorespro.com/rss/live-soccer.xml"
	response,err = http.request(url)
	for v in response:gmatch"<title>(.-)</title>" do
		ParseLine(v)	
	end
	--Core.SendToAll(response)
end

ParseLine = function(line)
	local e,s,A,B,score = string.find(line,"#(%S+) vs #(%S+): (%S+)%.")
	if not score then
		return true
	end	
	Core.SendToAll(A.." vs "..B.." Score : "..score)
	
end

Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTable) do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
			if(type(value) == "table") then
				Serialize(value,sKey,hFile,sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end

SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end