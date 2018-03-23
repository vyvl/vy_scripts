verify_path = Core.GetPtokaXPath().."scripts/".."verify.tbl"
require("socket")
http = require("socket.http")
JSON = require("JSON") --put JSON.lua inside "scripts/libs" folder. URL : https://github.com/jiyinyiyong/json-lua/blob/master/JSON.lua
http.TIMEOUT = 1
OWNER = "V10let" --change this nick to someone who maintains this script

queue = {}
OnStartup = function()
	interval = TmrMan.AddTimer(20*300,Fetches)
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
	if cmd =="verify" then
		verify[arg1] = arg2
		SaveToFile(verify_path,verify,"verify")		
		Core.SendToUser(user,arg1.." will be replaced with "..arg2)
		return true
	end
	if arg then
		arg = string.gsub(arg,"<","")
		arg = string.gsub(arg,">","")
	end
	if command == "next" then		
		local q = {["nick"] = user.sNick,["arg"] = arg,["type"] = "next", ["times"] = 0}
		table.insert(queue,q)
		--Core.SendToUser(user,Fetch(arg,"next"))
		return true
	elseif command == "last" then
	local q = {["nick"] = user.sNick,["arg"] = arg,["type"] = "last", ["times"] = 0}
		table.insert(queue,q)
		--Core.SendToUser(user,Fetch(arg,"last"))
		return true
	end
end

Fetches = function()


for p,v in pairs(queue) do
	if v["times"] == 4 then
		Core.SendToNick(v["nick"],"<[DeZire-BOT]> ".. "Series Not Found. If you think this is a mistake PM "..OWNER.."\n")
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
--    arg = Verify(arg)
    arg = string.gsub(arg," ","+")
    local url = "http://api.tvmaze.com/singlesearch/shows?q=".. arg .."&embed[]=nextepisode&embed[]=previousepisode"
    local response, err = http.request(url)

    local y = {}
    if response == nil or response == "" then
        return "Series not found"
    end

    y = JSON:decode(response)

    if y['status'] == nil then
        return "Series not found"
    end
    if type == "next" then
        if y['status'] == "Ended" then
        local prevEp = y['_embedded']['previousepisode']
            local date = prevEp['airdate']
            local episode = "[S"..prevEp['season'] .."E"..prevEp['number'].."] "
            local ret = "<[DeZire-BOT]> "..y['name'].." - Last episode: "..episode..prevEp['name'].." - "..date
            return ret
        end
        local nextEp = y['_embedded']['nextepisode']
        if nextEp == nil then
            local ret = "<[DeZire-BOT]> "..y['name'].." - "..y['status']
            return ret
        end
        local date = nextEp['airdate']
        local episode = "[S"..nextEp['season'] .."E"..nextEp['number'].."] "
        local ret = "<[DeZire-BOT]> "..y['name'].." - "..episode..nextEp['name'].." - "..date
        return ret
    elseif type =="last" then
        if y['status'] == 	"In Development" then
            local ret = "<[DeZire-BOT]> "..y['name'].." - Last: New Series"
            return ret
        end
        local prevEp = y['_embedded']['previousepisode']
        local date = prevEp['airdate']
        local episode = "[S"..prevEp['season'] .."E"..prevEp['number'].."] "
        local ret = "<[DeZire-BOT]> "..y['name'].." - Last episode: "..episode..prevEp['name'].." - "..date
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