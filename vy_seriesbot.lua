verify_path = Core.GetPtokaXPath().."scripts/".."verify.tbl"
require("socket")
http = require("socket.http")
http.TIMEOUT = 1
seriesbot = "[Series-BOT]"
queue = {}
OnStartup = function()
	--interval = TmrMan.AddTimer(20*300,Fetches)
	if loadfile(verify_path) then
		dofile(verify_path) -- this reads the words table from a file on disk and loads it to memory
	else
		verify = {}
		SaveToFile(verify_path,verify,"verify") -- creates a new table if it does not exist
	end
end

ChatArrival = function(user,data)
	local s,e,command,arg = string.find( data, "%b<> %p(%w+) (.+)|$")
	local s,e,cmd,arg1,arg2 = string.find( data, '%b<> %p(%w+) "(.-)" "(.-)"|$')
	local s,e,commands,nick,msg = string.find( data, "%b<> %p(%w+) (%S+)%s(.*)|$")
	if commands=="mc" then
		Core.SendToNick(nick,"<"..seriesbot..">".." "..msg)
		return true	
	end	
	if cmd =="verify" then
		verify[arg1] = arg2
		SaveToFile(verify_path,verify,"verify")		
		Core.SendToUser(user,arg1.." will be replaced with "..arg2)
		return true
	end
	--data:gsub(arg,Verify(arg))
	if command == "next" then		
		--local q = {["nick"] = user.sNick,["arg"] = arg,["type"] = "next", ["times"] = 0}
		--table.insert(queue,q)
		Core.SendToNick(seriesbot,data)
		--Core.SendToNick("V10let",data)
		return true
	elseif command == "last" then
		--local q = {["nick"] = user.sNick,["arg"] = arg,["type"] = "last", ["times"] = 0}
		--table.insert(queue,q)
		--Core.SendToUser(user,Fetch(arg,"last"))
		Core.SendToNick(seriesbot,data)

		return true
	end
end

Fetches = function()


for p,v in pairs(queue) do
	if v["times"] == 15 then
		Core.SendToNick(v["nick"],"<[DeZire-BOT]> ".. "Series Not Found. If you think this is a mistake PM V10let\n")
		table.remove(queue,p)
	end
	v["times"] = v["times"] + 1
	local ret = Fetch(v["arg"],v["type"])
	if(ret~="Series not found") then
		Core.SendToNick(v["nick"],ret)
		table.remove(queue,p)
	end

	
end

end

Fetch = function(arg,type)
	arg = Verify(arg)
	arg = string.gsub(arg," ","+")
	url = "http://services.tvrage.com/tools/quickinfo.php?show="..arg
	--Core.SendToAll(url)
	response,err = http.request(url)
	y = {}
	if response == nil then
		return "Series not found"
	end

	for i,v in response:gmatch"(.-)@(.-)\n" do
		y[i] = v
	end
	if y['Status'] == nil then
		return "Series not found"
	end
	if type == "next" then
		if y['Status'] == "Ended" then
			local e,s,ses,ep,name,mon,day,year = string.find(y['Latest Episode'],"(%d+)x(%d+)^(.+)^(.-)/(%d+)/(%d+)")
			local date = day.."-"..mon.."-"..year
			local episode = "[S"..ses.."E"..ep.."] "
			local ret = "<[DeZire-BOT]> "..y['Show Name'].." - Last episode: "..episode..name.." - "..date
			return ret
		end
		if y['Next Episode'] == nil then
			local ret = "<[DeZire-BOT]> "..y['Show Name'].." - "..y['Status']
			return ret
		end
		local e,s,ses,ep,name,mon,day,year = string.find(y['Next Episode'],"(%d+)x(%d+)^(.+)^(.-)/(%d+)/(%d+)")
		local date = day.."-"..mon.."-"..year
		local episode = "[S"..ses.."E"..ep.."] "
		local ret = "<[DeZire-BOT]> "..y['Show Name'].." - "..episode..name.." - "..date
		return ret
	elseif type =="last" then
		if y['Status'] == "New Series" then			
			local ret = "<[DeZire-BOT]> "..y['Show Name'].." - Last: New Series"
			return ret
		end
		local e,s,ses,ep,name,mon,day,year = string.find(y['Latest Episode'],"(%d+)x(%d+)^(.+)^(.-)/(%d+)/(%d+)")
		local date = day.."-"..mon.."-"..year
		local episode = "[S"..ses.."E"..ep.."] "
		local ret = "<[DeZire-BOT]> "..y['Show Name'].." - "..episode..name.." - "..date
		return ret
	end
end

Verify = function(arg)
	arg = string.lower(arg)
	if verify[arg] then
		return verify[arg]
	end
	return arg
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